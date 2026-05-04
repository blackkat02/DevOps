module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    vpc-cni    = { most_recent = true }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true } # Перенеси сюди, щоб не плодити окремі ресурси
  }

  eks_managed_node_groups = var.eks_managed_node_groups
}

resource "aws_iam_role" "jenkins_irsa" {
  name = "${var.cluster_name}-jenkins-irsa"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            # ВИПРАВЛЕНО: Використовуємо OIDC URL провайдера та правильний формат
            "${replace(module.eks.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins"
            "${replace(module.eks.oidc_provider, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr" {
  name = "jenkins-ecr"
  role = aws_iam_role.jenkins_irsa.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
  }

  depends_on = [module.eks] 
}