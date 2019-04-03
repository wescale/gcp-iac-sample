resource "google_compute_network" "lp-net" {
  name                    = "lp-net-${terraform.workspace}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lp-private-subnet" {
  name          = "lp-private-subnet-${terraform.workspace}"
  ip_cidr_range = "192.168.0.0/20"
  network       = "${google_compute_network.lp-net.self_link}"
  region        = "${var.region}"

  secondary_ip_range {
    range_name    = "${var.pod-net-name}"
    ip_cidr_range = "10.0.0.0/16"
  }

  secondary_ip_range {
    range_name    = "${var.svc-net-name}"
    ip_cidr_range = "10.1.0.0/16"
  }

  private_ip_google_access = true
}

resource "google_compute_router" "lp-router" {
  name    = "lp-router-${terraform.workspace}"
  region  = "${var.region}"
  network = "${google_compute_network.lp-net.self_link}"
}

resource "google_compute_router_nat" "lp-nat" {
  name                               = "nat-1-${terraform.workspace}"
  router                             = "${google_compute_router.lp-router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
