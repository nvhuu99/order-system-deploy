resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.17.7"
  namespace  = "kube-system"

  set = [
    { name = "fullnameOverride", value = "sealed-secrets-controller" },
  ]
}

resource "null_resource" "create_sealed_secrets" {
  depends_on = [helm_release.sealed_secrets]

  triggers = { run_once = "1" }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOT
    kubectl create ns monitoring 2>/dev/null || true && \
    kubectl create ns integration 2>/dev/null || true && \

    kubectl create secret generic grafana-secret \
      --namespace monitoring \
      --from-literal=admin-user=${var.grafana_admin_user} \
      --from-literal=admin-password=${var.grafana_admin_password} \
      --dry-run=client -o yaml | \
    kubeseal \
      --controller-name=sealed-secrets-controller \
      --controller-namespace=kube-system \
      --format yaml | \
    kubectl apply -f - && \

    kubectl create secret generic jenkins-secret \
      --namespace integration \
      --from-literal=jenkins-admin-user=${var.jenkins_admin_user} \
      --from-literal=jenkins-admin-password=${var.jenkins_admin_password} \
      --from-literal=docker-hub-user=${var.docker_hub_user} \
      --from-literal=docker-hub-password=${var.docker_hub_password} \
      --dry-run=client -o yaml | \
    kubeseal \
      --controller-name=sealed-secrets-controller \
      --controller-namespace=kube-system \
      --format yaml | \
    kubectl apply -f -
    EOT
  }
}
