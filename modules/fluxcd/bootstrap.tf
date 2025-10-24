resource "flux_bootstrap_git" "main" {
  embedded_manifests = true
  path               = "clusters/${var.environment}"
}