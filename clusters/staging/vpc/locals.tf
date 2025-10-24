locals {
  cluster_name = data.terraform_remote_state.root.outputs.cluster_name
  region       = data.terraform_remote_state.root.outputs.region
  vpc_cidr     = data.terraform_remote_state.root.outputs.vpc_cidr
  azs          = data.terraform_remote_state.root.outputs.azs
}