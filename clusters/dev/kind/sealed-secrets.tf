module "sealed_secrets" {
  source     = "../../../modules/sealed-secrets"
  depends_on = [module.kind]

  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password
  jenkins_admin_user     = var.jenkins_admin_user
  jenkins_admin_password = var.jenkins_admin_password
  docker_hub_user        = var.docker_hub_user
  docker_hub_password    = var.docker_hub_password
}