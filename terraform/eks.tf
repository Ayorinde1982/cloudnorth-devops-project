# eks.tf - Final Helm Method v2

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "cloudnorth-cluster-v2"
  cluster_version = "1.28"

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    general_purpose = {
      name           = "general-purpose-nodes"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }
}

resource "aws_iam_role" "lbc_role" {
  name = "eks-cloudnorth-lbc-role-helm"

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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })
}

# --- THIS SECTION IS NEW AND MORE RELIABLE ---

# 1. Download the policy document from the official AWS URL
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
}

# 2. Create the IAM policy from the downloaded document
resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy-CloudNorth"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = data.http.lbc_iam_policy.body
}

# 3. Attach the policy we just created to our role
resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn
  role       = aws_iam_role.lbc_role.name
}
