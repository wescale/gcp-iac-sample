resource "google_dns_record_set" "lp-a-public" {
  name = "public-ic.${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_global_address.lb-private-ip.address}"]
}

resource "google_dns_record_set" "lp-a-private" {
  name = "private-ic.${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_global_address.lb-private-ip.address}"]
}

resource "google_dns_record_set" "lp-a-consul" {
  name = "consul.${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_global_address.lb-private-ip.address}"]
}

resource "google_dns_record_set" "lp-a-admin" {
  name = "admin.${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_global_address.lb-private-ip.address}"]
}

resource "google_dns_record_set" "lp-global" {
  name = "${data.terraform_remote_state.layer-base.dns-public-zone}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.terraform_remote_state.layer-base.dns-public-zone-name}"

  rrdatas = ["${google_compute_global_address.lb-public-ip.address}"]
}
