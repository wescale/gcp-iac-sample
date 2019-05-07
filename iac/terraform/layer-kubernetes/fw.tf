resource "google_compute_firewall" "allow-private-hc-http-lb" {
  name    = "allow-private-hc-http-lb-${terraform.workspace}"
  network = "${data.terraform_remote_state.layer-base.lp-network-self-link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "30000-33000"]
  }

  source_ranges = ["${data.terraform_remote_state.layer-base.range-plateform}"]
  target_tags   = ["lp-cluster-${terraform.workspace}"]
}

resource "google_compute_firewall" "allow-private-http-lb-to-gke" {
  name      = "allow-private-http-lb-to-gke-${terraform.workspace}"
  network   = "${data.terraform_remote_state.layer-base.lp-network-self-link}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["32080"]
  }

  source_ranges = ["${data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal}"]
  target_tags   = ["kubernetes", "lp-cluster-${terraform.workspace}"]
}

resource "google_compute_firewall" "allow-public-hc-http-lb" {
  name    = "allow-public-hc-http-lb-${terraform.workspace}"
  network = "${data.terraform_remote_state.layer-base.lp-network-self-link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "30000-33000"]
  }

  source_ranges = ["${data.terraform_remote_state.layer-base.range-plateform}"]
  target_tags   = ["lp-cluster-${terraform.workspace}"]
}

resource "google_compute_firewall" "allow-public-http-lb-to-gke" {
  name      = "allow-public-http-lb-to-gke-${terraform.workspace}"
  network   = "${data.terraform_remote_state.layer-base.lp-network-self-link}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["31080"]
  }

  source_ranges = ["${data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal}"]
  target_tags   = ["kubernetes", "lp-cluster-${terraform.workspace}"]
}
