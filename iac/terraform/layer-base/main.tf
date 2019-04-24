provider "google" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

provider "google-beta" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

terraform {
  backend "gcs" {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-base"
  }
}
