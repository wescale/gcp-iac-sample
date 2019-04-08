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
