output "lp-network" {
  value = "${google_compute_network.lp-net.name}"
}

output "lp-network-self-link" {
  value = "${google_compute_network.lp-net.self_link}"
}

output "lp-sub-network" {
  value = "${google_compute_subnetwork.lp-private-subnet.name}"
}

output "lp-sub-network-self-link" {
  value = "${google_compute_subnetwork.lp-private-subnet.self_link}"
}

output "lp-sub-network-cidr" {
  value = "${var.range-ip}"
}

output "pod-net-name" {
  value = "${var.pod-net-name}"
}

output "svc-net-name" {
  value = "${var.svc-net-name}"
}

output "dns-private-zone" {
  value = "${google_dns_managed_zone.lp-private-zone.dns_name}"
}

output "dns-private-zone-name" {
  value = "${google_dns_managed_zone.lp-private-zone.name}"
}

output "dns-public-zone" {
  value = "${google_dns_managed_zone.lp-public-zone.dns_name}"
}

output "dns-public-zone-name" {
  value = "${google_dns_managed_zone.lp-public-zone.name}"
}

output "app_a_key" {
  value = "${google_service_account_key.app_a_key.private_key}"
}

output "range-plateform" {
  value = "${var.range-plateform}"
}
