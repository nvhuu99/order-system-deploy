resource "flux_bootstrap_git" "order_system_cicd" {
  embedded_manifests = true
  path               = "clusters/${local.env}"
}