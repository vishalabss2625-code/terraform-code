# AWS Cluster Management Project# EKS NGINX Deployment Project 🚀



This project contains Infrastructure as Code (IaC) and configurations for managing AWS clusters.A complete Amazon EKS (Elastic Kubernetes Service) deployment showcasing a custom NGINX web server with a beautiful modern HTML page.



## Project Structure![Kubernetes](https://img.shields.io/badge/kubernetes-1.32-blue)

![AWS](https://img.shields.io/badge/AWS-EKS-orange)

```![NGINX](https://img.shields.io/badge/nginx-latest-green)

terra-P/![Status](https://img.shields.io/badge/status-running-success)

├── terraform/          # Terraform configurations for AWS infrastructure

├── k8s-manifests/      # Kubernetes deployment manifests---

├── scripts/            # Setup and deployment scripts

└── README.md           # This file## 📖 Table of Contents

```

- [Overview](#overview)

## Prerequisites- [Architecture](#architecture)

- [Quick Start](#quick-start)

1. **AWS CLI** - Install and configure with your AWS credentials- [Project Structure](#project-structure)

2. **Terraform** - For infrastructure provisioning- [Documentation](#documentation)

3. **kubectl** - For Kubernetes cluster management (if using EKS)- [Access Information](#access-information)

4. **VS Code Extensions**:- [Technologies Used](#technologies-used)

   - AWS Toolkit- [Cost Information](#cost-information)

   - HashiCorp Terraform- [Cleanup](#cleanup)

   - Kubernetes

---

## Quick Start

## 🎯 Overview

### 1. Configure AWS Credentials

```powershellThis project demonstrates:

aws configure- ✅ Creating and managing an Amazon EKS cluster

```- ✅ Deploying applications using Kubernetes manifests

- ✅ Using ConfigMaps for application configuration

### 2. Deploy Infrastructure- ✅ Exposing services via AWS Load Balancer

```powershell- ✅ Managing namespaces and resources

cd terraform- ✅ Best practices for Kubernetes deployments

terraform init

terraform plan**Live Application:** http://a98b1fa1f505f4f95b5871404b2ab42c-1775659470.us-east-1.elb.amazonaws.com

terraform apply

```---



### 3. Connect to EKS Cluster (if using EKS)## 🏗️ Architecture

```powershell

aws eks update-kubeconfig --region us-west-2 --name my-cluster```

```AWS Cloud (us-east-1)

│

## Available Cluster Types├── EKS Cluster (my-eks-cluster)

│   ├── Control Plane (Managed by AWS)

1. **Amazon EKS (Elastic Kubernetes Service)**│   ├── VPC (192.168.0.0/16)

   - Managed Kubernetes service│   │   ├── Public Subnets (us-east-1b, us-east-1c)

   - Best for containerized applications│   │   └── Private Subnets (us-east-1b, us-east-1c)

   - Located in `terraform/eks/`│   │

│   └── Worker Nodes

2. **EC2 Cluster**│       ├── Node 1: t3.medium (us-east-1b)

   - Custom EC2 instances│       └── Node 2: t3.medium (us-east-1c)

   - Full control over the environment│

   - Located in `terraform/ec2-cluster/`└── Application (nginx namespace)

    ├── ConfigMap: nginx-html (Custom HTML)

## Getting Started    ├── Deployment: nginx-deployment (2 replicas)

    ├── Pods: 2× NGINX containers

Choose your cluster type and follow the respective README in each directory.    └── Service: LoadBalancer (AWS ELB)
```

---

## 🚀 Quick Start

### Prerequisites
- AWS Account with AdministratorAccess
- AWS CLI configured
- PowerShell (Windows)

### Installation

1. **Install eksctl:**
```powershell
# Create bin directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\bin" -Force

# Download and extract
Invoke-WebRequest -UseBasicParsing -OutFile "$env:TEMP\eksctl.zip" "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Windows_amd64.zip"
Expand-Archive -Path "$env:TEMP\eksctl.zip" -DestinationPath "$env:USERPROFILE\bin" -Force

# Add to PATH
$env:Path += ";$env:USERPROFILE\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)

# Verify
eksctl version
```

2. **Create EKS Cluster:**
```powershell
eksctl create cluster `
  --name my-eks-cluster `
  --region us-east-1 `
  --nodegroup-name standard-workers `
  --node-type t3.medium `
  --nodes 2 `
  --nodes-min 2 `
  --nodes-max 3 `
  --managed
```
*⏱️ Takes 15-20 minutes*

3. **Verify Cluster:**
```powershell
kubectl get nodes
```

4. **Deploy Application:**
```powershell
# Create namespace
kubectl create namespace nginx

# Apply manifests
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
```

5. **Get LoadBalancer URL:**
```powershell
kubectl get svc nginx-service -n nginx
```

6. **Access Application:**
Open the EXTERNAL-IP URL in your browser!

---

## 📁 Project Structure

```
terra-P/
│
├── docs/                           # 📚 Comprehensive Documentation
│   ├── PROJECT_OVERVIEW.md        # Complete project overview
│   ├── COMMANDS_REFERENCE.md      # All commands with explanations
│   └── CLUSTER_DETAILS.md         # Detailed cluster configuration
│
├── nginx-configmap.yaml           # 🎨 Custom HTML ConfigMap
├── nginx-deployment.yaml          # 🚢 NGINX Deployment manifest
├── nginx-service.yaml             # 🌐 LoadBalancer Service
│
└── README.md                      # This file
```

---

## 📚 Documentation

### Complete Guides

1. **[PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md)**
   - Architecture diagrams
   - Cluster information
   - Network configuration
   - Resource details
   - Cost breakdown
   - Success metrics

2. **[COMMANDS_REFERENCE.md](docs/COMMANDS_REFERENCE.md)**
   - 52+ commands with detailed explanations
   - AWS CLI commands
   - eksctl commands
   - kubectl commands
   - PowerShell commands
   - Troubleshooting guides

3. **[CLUSTER_DETAILS.md](docs/CLUSTER_DETAILS.md)**
   - Node specifications
   - IAM configuration
   - Namespace details
   - Resource usage
   - Security settings
   - Scaling strategies
   - Cleanup instructions

---

## 🌐 Access Information

### Application URL
```
http://a98b1fa1f505f4f95b5871404b2ab42c-1775659470.us-east-1.elb.amazonaws.com
```

### Cluster Details
- **Name:** my-eks-cluster
- **Region:** us-east-1
- **Kubernetes Version:** 1.32
- **Nodes:** 2× t3.medium
- **Namespace:** nginx

### Quick Access Commands
```powershell
# View all resources
kubectl get all -n nginx

# Get service URL
kubectl get svc nginx-service -n nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Open in browser
Start-Process "http://$(kubectl get svc nginx-service -n nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

---

## 🛠️ Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| **Amazon EKS** | Managed Kubernetes service | 1.32 |
| **eksctl** | EKS cluster management | 0.215.0 |
| **kubectl** | Kubernetes CLI | Compatible with 1.32 |
| **AWS CLI** | AWS management | v2 |
| **NGINX** | Web server | latest |
| **containerd** | Container runtime | 1.7.27 |
| **Amazon Linux 2023** | Node operating system | 9.20250929 |
| **AWS ELB** | Load balancing | Classic Load Balancer |

---

## 💰 Cost Information

### Monthly Running Costs

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| EKS Control Plane | 1 | $0.10/hour | $73.00 |
| t3.medium instances | 2 | $0.0416/hour | $60.00 |
| EBS volumes (20GB each) | 2 | $0.10/GB/month | $4.00 |
| Classic Load Balancer | 1 | $0.025/hour | $18.00 |
| Data Transfer | - | Variable | $5-10 |
| **Total Estimate** | - | - | **$160-165** |

### Cost Optimization Tips

1. **Use Spot Instances:** Save 60-70%
2. **Smaller instance type:** t3.small saves ~$30/month
3. **Delete when idle:** Zero cost
4. **Reserved Instances:** Up to 72% discount (1-year commit)
5. **Fargate:** Pay per pod (good for low-traffic apps)

---

## 🎨 Application Features

The custom NGINX page includes:

✨ **Design:**
- Beautiful purple gradient background
- Smooth slide-in animation
- Bouncing rocket emoji 🚀
- Professional card layout with shadows

📊 **Information Display:**
- Server type (NGINX on Kubernetes)
- Namespace indicator
- AWS region
- Status indicator

📱 **Responsive:**
- Works on desktop and mobile
- Clean, modern aesthetic
- Fast loading

---

## 📊 Cluster Specifications

### Control Plane
- Managed by AWS
- Multi-AZ deployment
- Kubernetes 1.32
- Public API endpoint

### Worker Nodes
- **Instance Type:** t3.medium (2 vCPU, 4GB RAM)
- **Count:** 2 nodes
- **OS:** Amazon Linux 2023
- **Container Runtime:** containerd
- **Zones:** us-east-1b, us-east-1c

### Networking
- **VPC:** 192.168.0.0/16
- **Public Subnets:** 192.168.0.0/19, 192.168.32.0/19
- **Private Subnets:** 192.168.64.0/19, 192.168.96.0/19
- **NAT Gateways:** 2 (high availability)

### Add-ons
- vpc-cni (Pod networking)
- kube-proxy (Network proxy)
- coredns (DNS)
- metrics-server (Resource metrics)

---

## 🔍 Monitoring

### View Cluster Status
```powershell
# Nodes
kubectl get nodes

# All resources in nginx namespace
kubectl get all -n nginx

# Resource usage
kubectl top nodes
kubectl top pods -n nginx

# Events
kubectl get events -n nginx --sort-by='.lastTimestamp'
```

### View Logs
```powershell
# All NGINX logs
kubectl logs -l app=nginx -n nginx --tail=50

# Specific pod
kubectl logs <pod-name> -n nginx

# Follow logs
kubectl logs -f -l app=nginx -n nginx
```

---

## 🔧 Management Commands

### Scale Application
```powershell
# Scale to 3 replicas
kubectl scale deployment nginx-deployment --replicas=3 -n nginx

# Scale to 1 replica
kubectl scale deployment nginx-deployment --replicas=1 -n nginx
```

### Update Configuration
```powershell
# Edit ConfigMap
kubectl edit configmap nginx-html -n nginx

# Restart deployment to pick up changes
kubectl rollout restart deployment nginx-deployment -n nginx
```

### Update NGINX Version
```powershell
# Update to specific version
kubectl set image deployment/nginx-deployment nginx=nginx:1.21 -n nginx

# Monitor rollout
kubectl rollout status deployment/nginx-deployment -n nginx

# Rollback if needed
kubectl rollout undo deployment/nginx-deployment -n nginx
```

---

## 🧹 Cleanup

### Delete Application Only
```powershell
kubectl delete -f nginx-service.yaml
kubectl delete -f nginx-deployment.yaml
kubectl delete -f nginx-configmap.yaml
kubectl delete namespace nginx
```

### Delete Entire Cluster
```powershell
eksctl delete cluster --name my-eks-cluster --region us-east-1
```
*⏱️ Takes 10-15 minutes*

**This will delete:**
- All pods and services
- Worker nodes
- VPC and subnets
- Security groups
- Load balancers
- IAM roles

---

## 🐛 Troubleshooting

### Cannot connect to cluster
```powershell
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify
kubectl get nodes
```

### Pods not starting
```powershell
# Check status
kubectl get pods -n nginx

# Check events
kubectl describe pod <pod-name> -n nginx

# Check logs
kubectl logs <pod-name> -n nginx
```

### LoadBalancer not accessible
```powershell
# Check service
kubectl get svc nginx-service -n nginx

# Wait 2-3 minutes for DNS propagation
# Test DNS resolution
nslookup <loadbalancer-url>
```

For more troubleshooting, see [COMMANDS_REFERENCE.md](docs/COMMANDS_REFERENCE.md#troubleshooting-commands).

---

## 📈 Next Steps

### Enhancements
1. **Add HTTPS:** Use AWS Certificate Manager + Ingress
2. **Auto-scaling:** Implement HPA and Cluster Autoscaler
3. **Monitoring:** Enable CloudWatch Container Insights
4. **Logging:** Enable CloudWatch logging
5. **CI/CD:** Integrate with GitHub Actions or AWS CodePipeline
6. **Security:** Add Network Policies and Pod Security Standards

### Learning Opportunities
- Helm charts for package management
- GitOps with ArgoCD or Flux
- Service mesh with Istio or App Mesh
- Secrets management with AWS Secrets Manager
- Multi-environment deployments

---

## 📝 Project Timeline

| Date | Activity |
|------|----------|
| Oct 16, 2025 | Initial cluster creation |
| Oct 16, 2025 | Troubleshooting connectivity |
| Oct 16, 2025 | eksctl installation |
| Oct 16, 2025 | NGINX deployment |
| Oct 17, 2025 | Documentation creation |

---

## 🎓 Skills Demonstrated

- ✅ AWS EKS cluster provisioning
- ✅ Kubernetes resource management
- ✅ ConfigMap and Secret handling
- ✅ Deployment strategies
- ✅ Service exposure via LoadBalancer
- ✅ Namespace organization
- ✅ YAML manifest creation
- ✅ CLI tool usage (aws, eksctl, kubectl)
- ✅ Troubleshooting and debugging
- ✅ Documentation

---

## 📞 Support & Resources

### Documentation
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [eksctl Documentation](https://eksctl.io/)
- [NGINX Documentation](https://nginx.org/en/docs/)

### Project Documentation
- [Complete Project Overview](docs/PROJECT_OVERVIEW.md)
- [Commands Reference](docs/COMMANDS_REFERENCE.md)
- [Cluster Details](docs/CLUSTER_DETAILS.md)

---

## 📜 License

This project is for educational and demonstration purposes.

---

## 👤 Author

**Created:** October 2025  
**AWS Account:** 266735813689  
**Region:** us-east-1

---

## ⭐ Acknowledgments

- AWS for EKS managed Kubernetes service
- eksctl team for the excellent cluster management tool
- Kubernetes community
- NGINX team

---

**Project Status:** ✅ Running and Accessible  
**Last Updated:** October 17, 2025

🚀 **Happy Kubernetes Learning!**
