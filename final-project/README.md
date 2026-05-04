# Final DevOps Project — AWS Infrastructure with CI/CD

## Overview

This project implements a production-ready infrastructure on AWS using Terraform, featuring a complete CI/CD pipeline with Jenkins and ArgoCD, Kubernetes workloads on EKS, PostgreSQL on RDS, and monitoring via Prometheus and Grafana.

## Architecture

┌────────────────────────────────────────────────────────┐
│                        AWS Cloud                       │
│                                                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │                  VPC (10.0.0.0/16)              │   │
│  │                                                 │   │
│  │  Public Subnets          Private Subnets        │   │
│  │  10.0.1-3.0/24           10.0.4-6.0/24          │   │
│  │       │                        │                │   │
│  │  [NAT Gateway]           [EKS Cluster]          │   │
│  │  [Internet GW]           [RDS PostgreSQL]       │   │
│  │                                                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                        │
│  [ECR Registry]   [S3 + DynamoDB] (Terraform state)    │
└────────────────────────────────────────────────────────┘

## Tech Stack

| Component | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Cloud Provider | AWS |
| Container Orchestration | EKS (Kubernetes 1.32) |
| CI | Jenkins |
| CD | ArgoCD |
| Database | RDS PostgreSQL 15 |
| Container Registry | ECR |
| Monitoring | Prometheus + Grafana |
| Application | Django (Python) |
| Container Build | Kaniko |

## Project Structure

final-project/
├── main.tf                  # Root module — connects all modules
├── backend.tf               # S3 + DynamoDB remote state
├── outputs.tf               # Root outputs
├── variables.tf             # Root variables
├── terraform.tfvars.example # Variable template (secrets excluded)
│
├── modules/
│   ├── s3-backend/          # S3 bucket + DynamoDB lock table
│   ├── vpc/                 # VPC, subnets, IGW, NAT, routes
│   ├── ecr/                 # ECR repository
│   ├── eks/                 # EKS cluster + node groups + IRSA
│   ├── rds/                 # RDS PostgreSQL + Aurora option
│   ├── jenkins/             # Jenkins via Helm
│   ├── argo_cd/             # ArgoCD via Helm + app charts
│   └── monitoring/          # Prometheus + Grafana via Helm
│
├── charts/
│   └── django-app/          # Helm chart for Django application
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       └── values.yaml
│
└── app/                     # Django application source
├── Dockerfile
├── Jenkinsfile
└── requirements.txt

## Infrastructure Components

### Networking
- VPC with public and private subnets across 3 availability zones
- Internet Gateway for public access
- NAT Gateway for private subnet outbound traffic
- Security Groups with least-privilege access rules

### EKS Cluster
- Kubernetes 1.32
- Managed node group with t3.small instances (auto-scaling 0–3)
- EBS CSI Driver for persistent volumes
- IRSA (IAM Roles for Service Accounts) for Jenkins ECR access

### CI/CD Pipeline
- **Jenkins** builds Docker images using Kaniko (no Docker daemon required)
- Images are pushed to ECR
- **ArgoCD** watches the Git repository and deploys updated Helm charts
- GitOps flow: code push → Jenkins build → image tag update → ArgoCD sync

### Security
- Private subnets for EKS nodes and RDS
- IAM roles with minimal required permissions
- IRSA for pod-level AWS access
- KMS encryption for EKS secrets
- RDS not publicly accessible
- Secrets managed via Kubernetes Secrets (not stored in Git)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0.0
- kubectl
- helm

## Deployment

### 1. Bootstrap state backend

```bash
# First run — create S3 and DynamoDB for state
cd modules/s3-backend
terraform init
terraform apply
```

### 2. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy infrastructure

```bash
terraform init
terraform apply
```

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name <cluster-name>
```

### 5. Verify deployment

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Accessing Services

```bash
# Jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins

# ArgoCD
kubectl port-forward svc/argocd-server 8081:80 -n argocd

# Grafana
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring
```

| Service | URL | Default credentials |
|---|---|---|
| Jenkins | http://localhost:8080 | admin / see tfvars |
| ArgoCD | http://localhost:8081 | admin / auto-generated |
| Grafana | http://localhost:3000 | admin / see tfvars |

## CI/CD Flow

Developer pushes code
│
▼
GitHub (main branch)
│
▼
Jenkins Pipeline
├── Build Docker image (Kaniko)
├── Push to ECR
└── Update image tag in values.yaml
│
▼
ArgoCD detects change
│
▼
Deploy to EKS

## Monitoring

Prometheus scrapes metrics from all cluster components. Grafana dashboards include:
- Kubernetes cluster overview
- Node resource utilization
- Pod CPU and memory usage
- Application-level metrics

## Cleanup

```bash
terraform destroy
```

> ⚠️ This will also delete the S3 bucket and DynamoDB table used for Terraform state. Back up your state file before destroying.

## Notes

- `terraform.tfvars` is excluded from Git via `.gitignore`
- `app/.env` is excluded from Git and Docker image via `.dockerignore`
- All sensitive values are passed via variables, never hardcoded