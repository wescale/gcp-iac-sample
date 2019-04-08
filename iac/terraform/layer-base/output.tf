output "lp-network" {
  value = "${google_compute_network.lp-net.name}"
}

output "lp-network-self-link" {
  value = "${google_compute_network.lp-net.self_link}"
}

output "lp-sub-network" {
  value = "${google_compute_subnetwork.lp-private-subnet.name}"
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
