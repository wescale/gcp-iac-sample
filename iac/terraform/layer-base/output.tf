output "lp-network" {
  value = "${google_compute_network.lp-net.name}"
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
