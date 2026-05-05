resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro" # Cost-effective burstable instance
  db_name                = "store_management"
  username               = "admin"
  password               = "PasswordSegura123!" # Usa variables en prod # Marked as sensitive
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_db_sg.id]
  
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "store-management-rds-subnet-group"
  subnet_ids = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Pass your 3 existing private subnet IDs here

  tags = {
    Name = "Store Management RDS Subnet Group"
  }
}