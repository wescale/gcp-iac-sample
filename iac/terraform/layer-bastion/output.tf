output "bastion-ip" {
  value = "${google_compute_instance.lp-bastion.network_interface.0.access_config.0.nat_ip}"
}
