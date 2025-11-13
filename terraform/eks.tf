# eks.tf - Defines the Amazon EKS cluster and its node groups

# This module creates the EKS cluster itself, along with the necessary IAM roles.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "cloudnorth-cluster" # Our official cluster name
  cluster_version = "1.28"

  # This connects the cluster to the VPC we defined in main.tf
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id] # Using the private subnets from main.tf

  # --- ADD THESE LINES TO ENABLE PUBLIC ACCESS ---
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  # ---------------------------------------------

  # This section defines the EC2 instances (nodes) that will run our containers.
  eks_managed_node_groups = {
    general_purpose = {
      name           = "general-purpose-nodes"
      min_size       = 1                # Minimum number of nodes
      max_size       = 3                # Maximum number of nodes for autoscaling
      desired_size   = 2                # The number of nodes to start with

      instance_types = ["t3.medium"]    # The type of EC2 instance to use
    }
  }
}
