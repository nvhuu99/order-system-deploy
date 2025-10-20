module "sealed_secrets" {
  source                           = "../../../modules/sealed-secrets"
  depends_on                       = [module.kind]
  linkerd_identity_ca_crt_path     = pathexpand("~/.sealed-secrets/linkerd-identity-ca.crt")
  linkerd_identity_issuer_crt_path = pathexpand("~/.sealed-secrets/linkerd-identity-issuer.crt")
  linkerd_identity_issuer_key_path = pathexpand("~/.sealed-secrets/linkerd-identity-issuer.key")
}