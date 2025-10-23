module "fluxcd" {
  source = "../../../modules/fluxcd"

  environment      = "staging"
  kube_config_path = local.kube_config_path

  git_repo_http_url = "https://github.com/nvhuu99/order-system-cicd.git"
  git_branch        = "main"
  git_username      = var.git_username
  git_password      = var.git_password
}
