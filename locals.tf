locals {
  env  = "staging"
  name = "${local.env}_order_system"

  kubernetes_version = "1.33"
  kube_config_path   = var.kube_config_path

  region   = "ap-southeast-7"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["ap-southeast-7a", "ap-southeast-7b"]

  github_username        = "nvhuu99"
  github_token           = var.github_token
  github_repo_http_url   = "https://github.com/nvhuu99/order-system-cicd.git"
  github_repo_visibility = "public"

  tags = {
    "kubernetes.io/cluster/staging_order_system" = "owned"
  }
}