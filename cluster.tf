resource "aws_eks_cluster" "main" {
  name    = local.name
  version = local.kubernetes_version

  role_arn = aws_iam_role.cluster.arn
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = local.tags
}

resource "null_resource" "update_local_kubeconfig" {
  depends_on = [aws_eks_cluster.main]
  triggers = {
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${local.region} --name ${aws_eks_cluster.main.name}"
  }
}

resource "aws_iam_role" "cluster" {
  name = "${local.name}_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}