resource "aws_db_instance" "this" {
  # Якщо use_aurora = false, створюємо 1 інстанс. Якщо true — 0.
  count = var.use_aurora ? 0 : 1

  identifier           = "${var.db_name}-instance"
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = 20
  
  # Основні параметри
  db_name     = "djangodb"
  db_user     = "dbadmin"
  db_password = var.db_password  # Мінімум 8 символів
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this[0].name
  
  skip_final_snapshot  = true
  publicly_accessible  = false

  tags = {
    Name = "${var.db_name}-instance"
  }
}