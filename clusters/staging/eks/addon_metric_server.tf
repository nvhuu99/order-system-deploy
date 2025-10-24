resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/charts/metrics-server/values.yaml")]

  depends_on = [
    aws_eks_node_group.general,
    null_resource.update_local_kubeconfig,
  ]
}