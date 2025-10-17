# Getting Started with AWS Clusters

This guide will walk you through creating and managing AWS clusters using this project.

## Prerequisites

Before you begin, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** installed (version >= 1.0)
4. **kubectl** (for EKS clusters)
5. **PowerShell** (Windows) or **Bash** (Linux/macOS)

## Quick Start

### Step 1: Configure AWS CLI

```powershell
# Run the AWS CLI setup script
.\scripts\setup-aws-cli.ps1

# Or configure manually
aws configure
```

### Step 2: Choose Your Cluster Type

#### Option A: Amazon EKS (Recommended for Kubernetes workloads)

```powershell
# Deploy EKS cluster
.\scripts\deploy.ps1 -ClusterType eks -Apply

# Configure kubectl
.\scripts\setup-kubectl.ps1 -ClusterName my-eks-cluster

# Deploy sample application
kubectl apply -f k8s-manifests\sample-app.yaml
```

#### Option B: EC2 Cluster (Custom applications)

```powershell
# Deploy EC2 cluster
.\scripts\deploy.ps1 -ClusterType ec2 -Apply
```

### Step 3: Verify Deployment

#### For EKS:
```powershell
kubectl get nodes
kubectl get pods --all-namespaces
```

#### For EC2:
- Check the load balancer URL from Terraform output
- Visit the URL in your browser

## Detailed Setup Instructions

### 1. AWS CLI Configuration

```powershell
# Install AWS CLI if not already installed
# Download from: https://aws.amazon.com/cli/

# Configure with your credentials
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-west-2)
# - Output format (json)

# Verify configuration
aws sts get-caller-identity
```

### 2. Terraform Installation

```powershell
# Windows (using Chocolatey)
choco install terraform

# Or download from: https://www.terraform.io/downloads.html
```

### 3. Customize Configuration

#### EKS Configuration:
Edit `terraform/eks/terraform.tfvars`:
```hcl
aws_region = "us-west-2"
cluster_name = "my-company-eks"
cluster_version = "1.28"
node_group_instance_types = ["t3.medium"]
node_group_desired_size = 3
```

#### EC2 Configuration:
Edit `terraform/ec2-cluster/terraform.tfvars`:
```hcl
aws_region = "us-west-2"
cluster_name = "my-company-ec2"
instance_type = "t3.medium"
desired_capacity = 2
```

## Available Commands

### Deployment Commands

```powershell
# Plan deployment (dry run)
.\scripts\deploy.ps1 -ClusterType eks

# Deploy cluster
.\scripts\deploy.ps1 -ClusterType eks -Apply

# Destroy cluster
.\scripts\deploy.ps1 -ClusterType eks -Destroy
```

### Kubernetes Commands (EKS only)

```powershell
# View cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Deploy applications
kubectl apply -f k8s-manifests\

# View pods
kubectl get pods --all-namespaces

# Get service URLs
kubectl get ingress
```

### Monitoring and Troubleshooting

```powershell
# View Terraform state
cd terraform\eks  # or terraform\ec2-cluster
terraform show

# View logs (EKS)
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# SSH to EC2 instances (EC2 cluster)
ssh -i ~/.ssh/your-key.pem ec2-user@<instance-ip>
```

## Project Structure Overview

```
terra-P/
├── terraform/
│   ├── eks/                    # EKS cluster configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── eks-cluster.tf
│   │   └── outputs.tf
│   └── ec2-cluster/           # EC2 cluster configuration
│       ├── main.tf
│       ├── variables.tf
│       ├── ec2-instances.tf
│       └── outputs.tf
├── k8s-manifests/             # Kubernetes deployment files
│   ├── sample-app.yaml
│   ├── aws-load-balancer-controller.yaml
│   └── monitoring.yaml
├── scripts/                   # Automation scripts
│   ├── setup-aws-cli.ps1
│   ├── setup-kubectl.ps1
│   └── deploy.ps1
└── README.md
```

## Common Use Cases

### 1. Development Environment

```powershell
# Small EKS cluster for development
.\scripts\deploy.ps1 -ClusterType eks -Apply
# Uses t3.medium instances, 2 nodes
```

### 2. Production Environment

Modify `terraform.tfvars` for production:
```hcl
environment = "production"
node_group_instance_types = ["m5.large"]
node_group_desired_size = 5
node_group_max_size = 10
```

### 3. Web Application Hosting

```powershell
# Deploy EC2 cluster with load balancer
.\scripts\deploy.ps1 -ClusterType ec2 -Apply
# Includes Auto Scaling Group and Application Load Balancer
```

## Security Considerations

1. **IAM Roles**: Use least privilege principle
2. **Security Groups**: Restrict access to necessary ports
3. **Encryption**: Enable encryption at rest and in transit
4. **Updates**: Keep clusters and nodes updated
5. **Monitoring**: Enable CloudWatch logging and monitoring

## Cost Optimization

1. **Instance Types**: Choose appropriate instance sizes
2. **Auto Scaling**: Use Auto Scaling to match demand
3. **Spot Instances**: Consider spot instances for dev/test
4. **Resource Limits**: Set resource requests and limits
5. **Cleanup**: Destroy unused clusters

```powershell
# Always clean up when done
.\scripts\deploy.ps1 -ClusterType eks -Destroy
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS CLI is configured
2. **Permissions**: Check IAM permissions for all services
3. **Quotas**: Verify AWS service quotas
4. **Region**: Ensure consistent region across configurations

### Getting Help

- Check Terraform output for detailed error messages
- Review AWS CloudWatch logs
- Validate configurations with `terraform plan`
- Use `kubectl describe` for Kubernetes issues

## Next Steps

1. Customize the configurations for your needs
2. Add your own applications to k8s-manifests/
3. Set up CI/CD pipelines
4. Configure monitoring and alerting
5. Implement backup and disaster recovery

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)