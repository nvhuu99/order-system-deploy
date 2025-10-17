output "aws_key_pair_private_key" {
  value     = tls_private_key.nodes.private_key_openssh
  sensitive = true
}
