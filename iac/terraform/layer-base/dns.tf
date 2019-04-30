resource "google_dns_managed_zone" "lp-private-zone" {
  provider = "google-beta"
  name     = "private-zone-${terraform.workspace}"

  //   don't forget the final dot "." !
  dns_name    = "${terraform.workspace}.internal.lp."
  description = "Private DNS zone for workspace ${terraform.workspace}"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "${google_compute_network.lp-net.self_link}"
    }
  }
}

data "google_dns_managed_zone" "lp-dns-public" {
  name = "slavayssiere-soa"
}

resource "google_dns_record_set" "lp-ns-root" {
  name = "${terraform.workspace}.${data.google_dns_managed_zone.lp-dns-public.dns_name}"
  type = "NS"
  ttl  = 300

  managed_zone = "${data.google_dns_managed_zone.lp-dns-public.name}"

  rrdatas = ["${google_dns_managed_zone.lp-public-zone.name_servers}"]
}

resource "google_dns_managed_zone" "lp-public-zone" {
  name        = "public-zone-${terraform.workspace}"
  dns_name    = "${terraform.workspace}.${data.google_dns_managed_zone.lp-dns-public.dns_name}"
  description = "SOA for ${terraform.workspace}"

  labels = {
    plateform = "${terraform.workspace}"
  }
}
