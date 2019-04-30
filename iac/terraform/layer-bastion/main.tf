provider "google" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

terraform {
  backend "gcs" {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-bastion"
  }
}

variable "remote_bucket" {}

variable "prefix_bucket" {}

data "terraform_remote_state" "layer-base" {
  backend = "gcs"

  config {
    bucket = "${var.remote_bucket}"
    path   = "${var.prefix_bucket}/layer-base/${terraform.workspace}.tfstate"
  }
}
