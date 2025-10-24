locals {
  env          = "staging"
  cluster_name = "${local.env}_order_system"

  kubernetes_version = "1.33"
  kube_config_path   = pathexpand("~/.kube/admin.conf")

  region   = "ap-southeast-7"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["ap-southeast-7a", "ap-southeast-7b"]
}