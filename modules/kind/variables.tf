variable "cluster_name" {
  type = string
}

variable "worker_count" {
  type        = number
  default     = 2
}

locals {
  worker_names = [for i in range(var.worker_count) : "${var.cluster_name}-worker-${i == 0 ? "" : i+1}"]
}
