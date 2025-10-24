resource "helm_release" "aws_ebs_csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.51.0"
  namespace  = "kube-system"

  set = [
    { name = "node.metadataSources", value = "kubernetes" },
    { name = "node.resources.requests.cpu", value = "25m" },
    { name = "node.resources.limits.cpu", value = "25m" },
    { name = "node.resources.requests.memory", value = "64Mi" },
    { name = "node.resources.limits.memory", value = "64Mi" },

    { name = "controller.region", value = local.region },
    { name = "controller.replicaCount", value = "1" },
    { name = "controller.resources.requests.cpu", value = "25m" },
    { name = "controller.resources.limits.cpu", value = "25m" },
    { name = "controller.resources.requests.memory", value = "64Mi" },
    { name = "controller.resources.limits.memory", value = "64Mi" },
  ]

  depends_on = [
    aws_eks_node_group.general,
    aws_iam_role_policy_attachment.aws_ebs_csi,
    null_resource.update_local_kubeconfig,
  ]
}

resource "aws_eks_pod_identity_association" "aws_ebs_csi" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.aws_ebs_csi.arn

  depends_on = [helm_release.aws_ebs_csi]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_iam_role" "aws_ebs_csi" {
  name = "aws_ebs_csi_role"
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
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_iam_role_policy_attachment" "aws_ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.aws_ebs_csi.name
}
