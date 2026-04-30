#Кластер Aurora
resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = "${var.db_name}-aurora-cluster"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
  
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
  
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.db_name}-aurora-instance"
  }
}