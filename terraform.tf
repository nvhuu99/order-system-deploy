terraform {
  required_version = "1.13.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
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
