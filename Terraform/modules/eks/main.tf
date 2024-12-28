resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id
  scaling_config {
    desired_size = var.node_group_size
    max_size     = 3
    min_size     = 1
  }
}

# Add VPC, IAM roles, and other resources as needed
