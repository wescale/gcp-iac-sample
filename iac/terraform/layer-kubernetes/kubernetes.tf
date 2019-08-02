resource "google_container_cluster" "lp-cluster" {
  provider = "google-beta"
  name     = "lp-cluster-${terraform.workspace}"
  location = "${var.region}"

  workload_identity_config {
    identity_namespace = "${var.gcp-project}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "${var.range_ip_master}"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${var.white-ip-1}"
      display_name = "white-ip-1"
    }

    cidr_blocks {
      cidr_block   = "${var.white-ip-2}"
      display_name = "white-ip-2"
    }

    cidr_blocks {
      cidr_block   = "${var.white-ip-3}"
      display_name = "white-ip-3"
    }

    cidr_blocks {
      cidr_block   = "${var.white-ip-4}"
      display_name = "white-ip-4"
    }

    cidr_blocks {
      cidr_block   = "${var.white-ip-5}"
      display_name = "white-ip-5"
    }

    cidr_blocks {
      cidr_block   = "81.250.133.68/32"
      display_name = "WeScale"
    }

    cidr_blocks {
      cidr_block   = "${data.terraform_remote_state.layer-bastion.bastion-ip}/32"
      display_name = "bastion-ip"
    }
  }

  min_master_version = "${var.k8s-version}"
  node_version       = "${var.k8s-version}"

  network    = "${data.terraform_remote_state.layer-base.lp-network-self-link}"
  subnetwork = "${data.terraform_remote_state.layer-base.lp-sub-network-self-link}"

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

  # FIXME: variabilize this
  cluster_autoscaling {
    enabled = "true"

    resource_limits {
      resource_type = "cpu"
      maximum       = "20"
      minimum       = "6"
    }

    resource_limits {
      resource_type = "memory"
      maximum       = "100"
      minimum       = "20"
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "np-default" {
  provider   = "google-beta"
  name       = "np-default-${terraform.workspace}"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.lp-cluster.name}"
  node_count = 2

  node_config {
    machine_type = "${var.instance-type}"
    preemptible  = "${var.preemptible}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    ]

    metadata {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    labels {
      Name      = "lp-cluster"
      Plateform = "${terraform.workspace}"
      NodePool  = "np-back"
    }

    tags = ["kubernetes", "lp-cluster-${terraform.workspace}"]
  }

  autoscaling {
    min_node_count = "${var.min_node}"
    max_node_count = "${var.max_node}"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
