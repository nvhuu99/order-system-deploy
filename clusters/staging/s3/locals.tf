locals {
  cluster_name   = data.terraform_remote_state.root.outputs.cluster_name
  node_role_name = data.terraform_remote_state.eks.outputs.nodes_role_name
  region         = data.terraform_remote_state.root.outputs.region
}