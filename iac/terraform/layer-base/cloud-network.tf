
resource "google_compute_global_address" "lp-cloud-private-ip" {
  name          = "lp-cloud-private-ip-${terraform.workspace}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.lp-net.self_link}"
}

resource "google_service_networking_connection" "lp-cloud-peering" {
  provider                = "google-beta"
  network                 = "${google_compute_network.lp-net.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.lp-cloud-private-ip.name}"]
}
