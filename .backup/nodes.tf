data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["k8s-v1.28.0-ubuntu-noble-24.04-amd64-hvm"]
  }

  owners = ["892464009377"]
}

resource "aws_instance" "kube_control_plane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.order_system_default.id]
  key_name                    = aws_key_pair.kube_system.key_name
  iam_instance_profile        = aws_iam_instance_profile.kube_control_plane.name

  user_data = templatefile("${path.module}/init-control-plane.sh.tpl", {
    pod_network_cidr    = "10.244.0.0/16"
    openssh_private_key = tls_private_key.kube_system.private_key_openssh
    kube_usr_pwd        = "1"
  })
}

resource "aws_instance" "kube_worker_1" {
  depends_on = [aws_instance.kube_control_plane]

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.order_system_default.id]
  key_name                    = aws_key_pair.kube_system.key_name
  iam_instance_profile        = aws_iam_instance_profile.kube_worker.name

  user_data = templatefile("${path.module}/init-worker.sh.tpl", {
    control_plane_ip    = aws_instance.kube_control_plane.private_ip
    openssh_private_key = tls_private_key.kube_system.private_key_openssh
    kube_usr_pwd        = "1"
  })
}
