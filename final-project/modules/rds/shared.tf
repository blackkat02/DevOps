# Група підмереж (використовуємо приватні підмережі з VPC)
resource "aws_db_subnet_group" "this" {
  name = "${var.db_name}-subnet-group-v2"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.db_name}-subnet-group-v2"
  }
}

# Security Group для бази даних
resource "aws_security_group" "rds" {
  name = "${var.db_name}-rds-sg-v2"
  description = "Allow inbound traffic for RDS from EKS"
  vpc_id      = var.vpc_id

  # Вхідний трафік: Тільки з нашого EKS кластера (БЕЗПЕКА)
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_name}-rds-sg"
  }
}

# Parameter Group (універсальна для обох типів)
resource "aws_db_parameter_group" "this" {
  count  = var.use_aurora ? 0 : 1
  name = "${var.db_name}-params-v2"
  family = var.db_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot" # Додай цей рядок
  }
}