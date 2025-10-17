# kubectl Setup Script for EKS
# Run this script to configure kubectl for your EKS cluster

param(
    [string]$ClusterName = "my-eks-cluster",
    [string]$Region = "us-west-2",
    [string]$AwsProfile = "default"
)

Write-Host "Setting up kubectl for EKS cluster..." -ForegroundColor Green

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client=true --short 2>$null
    Write-Host "kubectl found: $kubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "kubectl not found. Installing kubectl..." -ForegroundColor Yellow
    
    # Download and install kubectl for Windows
    $kubectlUrl = "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
    $kubectlPath = "$env:USERPROFILE\.local\bin\kubectl.exe"
    
    # Create directory if it doesn't exist
    $binDir = Split-Path $kubectlPath -Parent
    if (!(Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force
    }
    
    # Download kubectl
    Invoke-WebRequest -Uri $kubectlUrl -OutFile $kubectlPath
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
    if ($currentPath -notlike "*$binDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$binDir", [EnvironmentVariableTarget]::User)
        $env:PATH = "$env:PATH;$binDir"
    }
    
    Write-Host "kubectl installed successfully!" -ForegroundColor Green
}

# Update kubeconfig for EKS cluster
Write-Host "`nConfiguring kubectl for EKS cluster: $ClusterName" -ForegroundColor Yellow

try {
    if ($AwsProfile -ne "default") {
        aws eks update-kubeconfig --region $Region --name $ClusterName --profile $AwsProfile
    } else {
        aws eks update-kubeconfig --region $Region --name $ClusterName
    }
    
    Write-Host "✓ kubectl configured successfully!" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to configure kubectl. Make sure your EKS cluster exists." -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Test cluster connection
Write-Host "`nTesting cluster connection..." -ForegroundColor Yellow
try {
    $nodes = kubectl get nodes --no-headers 2>$null
    if ($nodes) {
        Write-Host "✓ Successfully connected to cluster!" -ForegroundColor Green
        Write-Host "Cluster nodes:" -ForegroundColor Cyan
        kubectl get nodes
    } else {
        Write-Host "⚠ Connected to cluster but no nodes found. Cluster may still be starting up." -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Failed to connect to cluster." -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

# Install AWS Load Balancer Controller (optional)
Write-Host "`nWould you like to install AWS Load Balancer Controller? (y/N)" -ForegroundColor Yellow
$installALB = Read-Host
if ($installALB -eq 'y' -or $installALB -eq 'Y') {
    Write-Host "Installing AWS Load Balancer Controller..." -ForegroundColor Green
    
    # Apply the controller manifest
    $manifestPath = Join-Path (Split-Path $PSScriptRoot -Parent) "k8s-manifests\aws-load-balancer-controller.yaml"
    if (Test-Path $manifestPath) {
        kubectl apply -f $manifestPath
        Write-Host "✓ AWS Load Balancer Controller deployed!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Load balancer controller manifest not found at: $manifestPath" -ForegroundColor Yellow
    }
}

Write-Host "`nkubectl setup completed!" -ForegroundColor Green
Write-Host "`nUseful kubectl commands:" -ForegroundColor Yellow
Write-Host "• View cluster info: kubectl cluster-info" -ForegroundColor Cyan
Write-Host "• List nodes: kubectl get nodes" -ForegroundColor Cyan
Write-Host "• List all pods: kubectl get pods --all-namespaces" -ForegroundColor Cyan
Write-Host "• View cluster events: kubectl get events --sort-by='.lastTimestamp'" -ForegroundColor Cyan