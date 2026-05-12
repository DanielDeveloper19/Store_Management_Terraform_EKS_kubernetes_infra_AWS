
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description       = "allow inbound traffic from eks"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "control_plane_to_webhook" {
  description              = "Allow EKS Control Plane to reach ALB Controller Webhook"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.all_worker_mgmt.id
  type                     = "ingress"
  
  # This targets the specific security group of your cluster 
  # rather than a wide IP range.
  source_security_group_id = module.eks.cluster_primary_security_group_id 
}


#-----------------------------------------------------

resource "aws_security_group" "rds_db_sg" {
  name        = "store-management-rds-db-sg"
  description = "Allow inbound traffic from EKS worker nodes only"
  vpc_id      = module.vpc.vpc_id # Your existing VPC ID

  # Inbound rule: Only allow EKS nodes to connect to MySQL
  ingress {
    description     = "Allow MySQL traffic from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.all_worker_mgmt.id] # Your EKS Node Security Group ID
  }

  # Outbound rule: Allow RDS to send responses back out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}