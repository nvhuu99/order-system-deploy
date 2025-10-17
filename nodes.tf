resource "aws_eks_node_group" "general" {
  node_group_name = "general"
  cluster_name    = aws_eks_cluster.main.name
  version         = aws_eks_cluster.main.version

  subnet_ids = module.vpc.private_subnets

  node_role_arn = aws_iam_role.nodes.arn

  launch_template {
    id      = aws_launch_template.general.id
    version = "$Latest"
  }

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 0
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly,
  ]

  # Allow Autoscaler to override the desired_size
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  labels = {
    role = "general"
  }

  tags = local.tags
}

resource "aws_launch_template" "general" {
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
    }
  }

  # This allow addons, drivers to fetch metadata without rely on IMDSv2
  # Instead, to fetch metadata, they will use region, vpcId, zone, nodeId ...
  # e.g: AWS Load Balancer Controller, AWS EBS CSI
  metadata_options {
    http_put_response_hop_limit = 1
  }
}

resource "aws_iam_role" "nodes" {
  name = "${local.name}_nodes_role"
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
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}
