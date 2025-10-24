resource "aws_eks_node_group" "general" {
  node_group_name = "general"
  cluster_name    = aws_eks_cluster.main.name
  version         = aws_eks_cluster.main.version

  subnet_ids = local.private_subnets

  node_role_arn = aws_iam_role.nodes.arn

  launch_template {
    id      = aws_launch_template.general.id
    version = "1"
  }

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 5
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

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_launch_template" "general" {
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
    }
  }

  # This allow addons, drivers to fetch metadata with IMDSv2
  # Without this, some addon will not work (e.g. aws ebs csi, aws lbc)
  metadata_options {
    http_put_response_hop_limit = 3
  }
}
