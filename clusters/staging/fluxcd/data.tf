data "terraform_remote_state" "root" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}