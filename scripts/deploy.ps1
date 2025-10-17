# Deployment Scripts for Terra-P AWS Clusters
# Choose which cluster type to deploy

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("eks", "ec2")]
    [string]$ClusterType,
    
    [string]$ClusterName,
    [string]$Region = "us-west-2",
    [switch]$Apply,
    [switch]$Destroy
)

$ErrorActionPreference = "Stop"

# Set default cluster names if not provided
if (-not $ClusterName) {
    $ClusterName = if ($ClusterType -eq "eks") { "my-eks-cluster" } else { "my-ec2-cluster" }
}

Write-Host "AWS Cluster Deployment Script" -ForegroundColor Green
Write-Host "Cluster Type: $ClusterType" -ForegroundColor Cyan
Write-Host "Cluster Name: $ClusterName" -ForegroundColor Cyan
Write-Host "Region: $Region" -ForegroundColor Cyan

# Set terraform directory
$terraformDir = Join-Path $PSScriptRoot "..\terraform\$ClusterType"

if (!(Test-Path $terraformDir)) {
    Write-Host "Error: Terraform directory not found: $terraformDir" -ForegroundColor Red
    exit 1
}

Set-Location $terraformDir

# Check if terraform.tfvars exists
$tfvarsPath = Join-Path $terraformDir "terraform.tfvars"
if (!(Test-Path $tfvarsPath)) {
    Write-Host "Creating terraform.tfvars from example..." -ForegroundColor Yellow
    $examplePath = Join-Path $terraformDir "terraform.tfvars.example"
    if (Test-Path $examplePath) {
        Copy-Item $examplePath $tfvarsPath
        
        # Update default values in terraform.tfvars
        $content = Get-Content $tfvarsPath -Raw
        $content = $content -replace 'cluster_name = ".*"', "cluster_name = `"$ClusterName`""
        $content = $content -replace 'aws_region = ".*"', "aws_region = `"$Region`""
        Set-Content $tfvarsPath $content
        
        Write-Host "✓ Created terraform.tfvars with your settings" -ForegroundColor Green
        Write-Host "Please review and edit terraform.tfvars if needed" -ForegroundColor Yellow
    }
}

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Terraform init failed" -ForegroundColor Red
    exit 1
}

# Plan or Apply
if ($Destroy) {
    Write-Host "`nPlanning destruction..." -ForegroundColor Red
    terraform plan -destroy
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nDo you want to destroy the cluster? (type 'yes' to confirm): " -ForegroundColor Red -NoNewline
        $confirmation = Read-Host
        if ($confirmation -eq "yes") {
            terraform destroy -auto-approve
        } else {
            Write-Host "Destruction cancelled." -ForegroundColor Yellow
        }
    }
} elseif ($Apply) {
    Write-Host "`nPlanning deployment..." -ForegroundColor Yellow
    terraform plan
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nApplying configuration..." -ForegroundColor Green
        terraform apply -auto-approve
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✓ Cluster deployed successfully!" -ForegroundColor Green
            
            # Show outputs
            Write-Host "`nCluster Information:" -ForegroundColor Cyan
            terraform output
            
            # Additional setup for EKS
            if ($ClusterType -eq "eks") {
                Write-Host "`nConfiguring kubectl..." -ForegroundColor Yellow
                $setupScript = Join-Path $PSScriptRoot "setup-kubectl.ps1"
                if (Test-Path $setupScript) {
                    & $setupScript -ClusterName $ClusterName -Region $Region
                }
            }
        }
    }
} else {
    Write-Host "`nRunning plan..." -ForegroundColor Yellow
    terraform plan
    
    Write-Host "`nTo apply this configuration, run:" -ForegroundColor Green
    Write-Host "  .\deploy.ps1 -ClusterType $ClusterType -Apply" -ForegroundColor Gray
    Write-Host "`nTo destroy the cluster, run:" -ForegroundColor Red
    Write-Host "  .\deploy.ps1 -ClusterType $ClusterType -Destroy" -ForegroundColor Gray
}

Write-Host "`nDeployment script completed." -ForegroundColor Green