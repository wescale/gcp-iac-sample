resource "google_compute_instance" "lp-bastion" {
  name         = "bastion-${terraform.workspace}"
  machine_type = "${var.instance_type}"
  zone         = "${var.region}-b"

  tags = ["bastion", "${terraform.workspace}"]

  boot_disk {
    initialize_params {
      image = "${var.instance_image}"
    }
  }

  network_interface {
    network    = "${data.terraform_remote_state.layer-base.lp-network-self-link}"
    subnetwork = "${data.terraform_remote_state.layer-base.lp-sub-network-self-link}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  metadata = {
    plateform = "${terraform.workspace}"
  }
}