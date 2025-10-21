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

resource "null_resource" "linkerd_identity_ca" {
  depends_on = [helm_release.sealed_secrets]

  triggers = { run_once = "1" }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOT
    kubectl create secret generic linkerd-identity-ca-crt --namespace linkerd --from-file="${var.linkerd_identity_ca_crt_path}/linkerd-identity-ca.crt" --dry-run=client -o yaml | \
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format yaml | \
    kubectl apply -f - && \

    kubectl create secret generic linkerd-identity-issuer-crt --namespace linkerd --from-file="${var.linkerd_identity_issuer_crt_path}/linkerd-identity-issuer.crt" --dry-run=client -o yaml | \
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format yaml | \
    kubectl apply -f - && \

    kubectl create secret generic linkerd-identity-issuer-key --namespace linkerd --from-file="${var.linkerd_identity_issuer_key_path}/linkerd-identity-issuer.key" --dry-run=client -o yaml | \
    kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format yaml | \
    kubectl apply -f -
    EOT
  }
}
