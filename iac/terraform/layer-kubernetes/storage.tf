resource "google_storage_bucket" "lp-public-static-bucket" {
  name          = "lp-public-static-bucket-${terraform.workspace}"
  location      = "${var.region}"
  force_destroy = true
}

resource "google_storage_bucket" "lp-private-static-bucket" {
  name          = "lp-private-static-bucket-${terraform.workspace}"
  location      = "${var.region}"
  force_destroy = true
}
