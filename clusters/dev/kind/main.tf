module "kind" {
  source       = "../../../modules/kind"
  cluster_name = "dev"
  worker_count = 2
}