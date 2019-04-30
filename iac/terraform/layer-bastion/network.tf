resource "google_dns_record_set" "lp-bastion-dns" {
  name = "bastion.${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_instance.lp-bastion.network_interface.0.access_config.0.nat_ip }"]
}

resource "google_compute_firewall" "lp-bastion-external" {
  name    = "lp-bastion-external-${terraform.workspace}"
  network = "${data.terraform_remote_state.layer-base.lp-network-self-link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion", "${terraform.workspace}"]
}

resource "google_compute_firewall" "lp-bastion-gke" {
  name    = "lp-bastion-gke-${terraform.workspace}"
  network = "${data.terraform_remote_state.layer-base.lp-network-self-link}"

  allow {
    protocol = "tcp"
    ports    = ["30000-33000"]
  }

  target_tags = ["kubernetes", "lp-cluster-${terraform.workspace}"]
  source_tags = ["bastion", "${terraform.workspace}"]
}
