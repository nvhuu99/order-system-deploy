terraform {
  required_version = "1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "1.7.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-7"

  default_tags {
    tags = {
      "Namespace" = "order_system"
    }
  }
}

provider "flux" {
  kubernetes = {
    config_path = local.kube_config_path
  }
  git = {
    url = local.github_repo_http_url
    http = {
      username = local.github_username
      password = local.github_token
    }
  }
}
