# outputs.tf - Defines the output variables from our Terraform deployment

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS control plane (API server)."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster."
  value       = module.eks.cluster_version
}

output "vpc_id" {
  description = "The ID of the VPC where the cluster is deployed."
  value       = aws_vpc.main.id
}
