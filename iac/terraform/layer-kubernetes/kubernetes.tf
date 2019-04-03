resource "google_container_cluster" "lp-cluster" {
  provider = "google-beta"
  name     = "lp-cluster-${terraform.workspace}"
  location = "${var.region}"

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "192.168.16.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${var.myip}/32"
      display_name = "dyn"
    }
  }

  min_master_version = "1.12.5-gke.5"
  node_version       = "1.12.5-gke.5"

  network    = "${data.terraform_remote_state.layer-base.lp-network}"
  subnetwork = "${data.terraform_remote_state.layer-base.lp-sub-network}"

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${data.terraform_remote_state.layer-base.pod-net-name}"
    services_secondary_range_name = "${data.terraform_remote_state.layer-base.svc-net-name}"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "np-default" {
  provider   = "google-beta"
  name       = "np-default-${terraform.workspace}"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.lp-cluster.name}"
  node_count = 1

  node_config {
    machine_type = "n1-standard-1"
    preemptible  = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/cloud-language",
    ]

    labels {
      Name      = "lp-cluster"
      Plateform = "${terraform.workspace}"
    }

    tags = ["kubernetes", "lp-cluster-${terraform.workspace}"]
  }
}
