terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.bucket_name
  table_name  = var.table_name
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-10-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-10-ecr"
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "django-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.small"]
      min_size       = 0
      max_size       = 3
      desired_size   = 2

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
      }
    }
  }
}

module "jenkins" {
  source       = "./modules/jenkins"
  admin_password = var.admin_password
  cluster_name = module.eks.cluster_name
  depends_on   = [module.eks]
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  cluster_name = module.eks.cluster_name
  depends_on   = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  # Основні параметри
  db_name      = "djangodb"
  db_user      = "dbadmin"
  db_password = var.db_password
  
  # Мережеві налаштування
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_primary_security_group_id

  use_aurora = var.use_aurora

  # Налаштування двигуна (для RDS)
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  db_family      = "postgres15"
  db_port        = 5432
}