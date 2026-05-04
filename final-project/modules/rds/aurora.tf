# Aurora Parameter Groups
resource "aws_rds_cluster_parameter_group" "this" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.db_name}-cluster-params"
  family = var.db_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_parameter_group" "aurora_instance" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.db_name}-aurora-instance-params"
  family = var.db_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }
}

#Кластер Aurora
resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = "${var.db_name}-aurora-cluster"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  
  skip_final_snapshot     = true

  tags = {
    Name = "${var.db_name}-aurora-cluster"
  }
}

# Інстанс всередині кластера (Writer)
resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.db_name}-aurora-instance"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
  db_parameter_group_name = aws_db_parameter_group.aurora_instance[0].name
  
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.db_name}-aurora-instance"
  }
}