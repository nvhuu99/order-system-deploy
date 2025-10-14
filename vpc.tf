module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "order-system-vpc"
  tags   = { Namespace = "order-system" }

  cidr            = "10.0.0.0/16"
  azs             = ["ap-southeast-7a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}