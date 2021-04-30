data "digitalocean_kubernetes_versions" "example" {
  version_prefix = "1.20."
}

resource "digitalocean_kubernetes_cluster" "blimp" {
  name         = "blimp"
  region       = "nyc3"
  version      = data.digitalocean_kubernetes_versions.example.latest_version
  auto_upgrade = true

  # This default node pool is mandatory
  node_pool {
    name       = "pool-e033tahy7"
    size       = "s-2vcpu-4gb"
    auto_scale = false
    node_count = 1
  }
}