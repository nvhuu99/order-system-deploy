resource "kind_cluster" "main" {
  name            = var.cluster_name
  node_image      = "kindest/node:v1.32.8"
  kubeconfig_path = pathexpand("~/.kind/admin.conf")
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    dynamic "node" {
      for_each = toset([for i in range(var.worker_count) : i])
      content {
        role = "worker"
      }
    }
  }
}

resource "null_resource" "cluster_resource_limit" {
  depends_on = [kind_cluster.main]

  triggers = { cluster_endpoint = kind_cluster.main.endpoint }

  provisioner "local-exec" {
    command = <<EOT
    docker update --cpus=1 --memory=1g --memory-swap=3g ${var.cluster_name}-control-plane
    ${join("\n", [
      for name in local.worker_names :
      format("docker update --cpus=3 --memory=3g --memory-swap=6g %s", name)
    ])}
    EOT
  }
}

