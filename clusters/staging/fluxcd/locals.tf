locals {
  kube_config_path = data.terraform_remote_state.root.outputs.kube_config_path
}