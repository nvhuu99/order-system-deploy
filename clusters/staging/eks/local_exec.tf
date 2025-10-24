resource "null_resource" "update_local_kubeconfig" {
  depends_on = [
    aws_eks_node_group.general,
  ]
  triggers = {
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${local.region} --name ${aws_eks_cluster.main.name}"
  }
}