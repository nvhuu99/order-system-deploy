locals {
  kubernetes_version = data.terraform_remote_state.root.outputs.kubernetes_version
  cluster_name       = data.terraform_remote_state.root.outputs.cluster_name
  region             = data.terraform_remote_state.root.outputs.region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets     = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets    = data.terraform_remote_state.vpc.outputs.private_subnets
}