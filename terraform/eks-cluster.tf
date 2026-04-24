module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

# 1. Ensure the public endpoint is active
  cluster_endpoint_public_access = true

  # 2. Add your current IP to the security group rules
  # This allows your local kubectl to talk to the EKS API
  cluster_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      description = "Allow local machine to access API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"] # For testing. Change to your actual IP for security.
    }}

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  tags = {
    cluster = "demo"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    capacity_type  = "ON_DEMAND" # Forces AWS to look past Free Tier
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }
}

