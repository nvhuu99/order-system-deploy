locals {
  env  = "staging"
  name = "${local.env}_order_system"

  kubernetes_version = "1.33"

  region   = "ap-southeast-7"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["ap-southeast-7a", "ap-southeast-7b"]

  tags = {
    "kubernetes.io/cluster/staging_order_system" = "owned"
  }
}