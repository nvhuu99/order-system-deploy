output "aws_key_pair_private_key" {
  value     = tls_private_key.kube_system.private_key_openssh
  sensitive = true
}

output "control_plane_public_ip" {
  value = aws_instance.kube_control_plane.public_ip
}

output "worker_1_public_ip" {
  value = aws_instance.kube_worker_1.public_ip
}