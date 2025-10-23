resource "tls_private_key" "nodes" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nodes" {
  key_name   = "${local.cluster_name}_nodes_keypair"
  public_key = tls_private_key.nodes.public_key_openssh

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
