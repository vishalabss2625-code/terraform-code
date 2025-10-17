# Quick initialization script for the EKS cluster
# Run this script to initialize and validate the Terraform configuration

param(
    [switch]$Init,
    [switch]$Plan,
    [switch]$Apply,
    [switch]$Destroy
)

$ErrorActionPreference = "Stop"

Write-Host "EKS Cluster Management Script" -ForegroundColor Green

# Ensure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$eksPath = Join-Path $scriptPath "..\terraform\eks"
Set-Location $eksPath

Write-Host "Working in directory: $(Get-Location)" -ForegroundColor Cyan

if ($Init -or (-not $Plan -and -not $Apply -and -not $Destroy)) {
    Write-Host "`nInitializing Terraform..." -ForegroundColor Yellow
    terraform init
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Terraform initialized successfully!" -ForegroundColor Green
        
        Write-Host "`nValidating configuration..." -ForegroundColor Yellow
        terraform validate
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Configuration is valid!" -ForegroundColor Green
        } else {
            Write-Host "✗ Configuration validation failed!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✗ Terraform initialization failed!" -ForegroundColor Red
        exit 1
    }
}

if ($Plan) {
    Write-Host "`nCreating execution plan..." -ForegroundColor Yellow
    terraform plan
}

if ($Apply) {
    Write-Host "`nApplying configuration..." -ForegroundColor Green
    terraform apply
}

if ($Destroy) {
    Write-Host "`nDestroying infrastructure..." -ForegroundColor Red
    terraform destroy
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Copy terraform.tfvars.example to terraform.tfvars" -ForegroundColor Cyan
Write-Host "2. Edit terraform.tfvars with your settings" -ForegroundColor Cyan
Write-Host "3. Run: .\init-eks.ps1 -Plan" -ForegroundColor Cyan
Write-Host "4. Run: .\init-eks.ps1 -Apply" -ForegroundColor Cyan