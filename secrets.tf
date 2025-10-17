resource "tls_private_key" "nodes" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nodes" {
  key_name   = "${local.name}_nodes_keypair"
  public_key = tls_private_key.nodes.public_key_openssh

  tags = local.tags
}
