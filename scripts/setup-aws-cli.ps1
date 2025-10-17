# AWS CLI Configuration Script for Windows PowerShell
# Run this script to configure AWS CLI and set up your environment

param(
    [string]$AwsProfile = "default",
    [string]$Region = "us-west-2"
)

Write-Host "Setting up AWS CLI Configuration..." -ForegroundColor Green

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version
    Write-Host "AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "AWS CLI not found. Please install AWS CLI first:" -ForegroundColor Red
    Write-Host "https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Configure AWS CLI
Write-Host "`nConfiguring AWS CLI profile: $AwsProfile" -ForegroundColor Yellow
Write-Host "You will need to provide:" -ForegroundColor Cyan
Write-Host "1. AWS Access Key ID" -ForegroundColor Cyan
Write-Host "2. AWS Secret Access Key" -ForegroundColor Cyan
Write-Host "3. Default region: $Region" -ForegroundColor Cyan
Write-Host "4. Default output format: json" -ForegroundColor Cyan

aws configure --profile $AwsProfile

# Verify configuration
Write-Host "`nVerifying AWS configuration..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --profile $AwsProfile --output json | ConvertFrom-Json
    Write-Host "✓ AWS configuration successful!" -ForegroundColor Green
    Write-Host "Account ID: $($identity.Account)" -ForegroundColor Cyan
    Write-Host "User ARN: $($identity.Arn)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ AWS configuration failed. Please check your credentials." -ForegroundColor Red
    exit 1
}

# Set default profile if not specified
if ($AwsProfile -ne "default") {
    $env:AWS_PROFILE = $AwsProfile
    Write-Host "`nSet AWS_PROFILE environment variable to: $AwsProfile" -ForegroundColor Green
    Write-Host "To make this permanent, add it to your PowerShell profile:" -ForegroundColor Yellow
    Write-Host "`$env:AWS_PROFILE = '$AwsProfile'" -ForegroundColor Gray
}

Write-Host "`nAWS CLI setup completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Navigate to terraform/eks or terraform/ec2-cluster directory" -ForegroundColor Cyan
Write-Host "2. Copy terraform.tfvars.example to terraform.tfvars" -ForegroundColor Cyan
Write-Host "3. Edit terraform.tfvars with your desired settings" -ForegroundColor Cyan
Write-Host "4. Run: terraform init" -ForegroundColor Cyan
Write-Host "5. Run: terraform plan" -ForegroundColor Cyan
Write-Host "6. Run: terraform apply" -ForegroundColor Cyan