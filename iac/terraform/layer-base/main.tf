provider "google" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

variable "gcp-project" {
  default = "livingpackets-sandbox"
}

variable "region" {
  default = "europe-west3"
}

terraform {
  backend "gcs" {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-base"
  }
}

data "terraform_remote_state" "layer-project" {
  backend = "gcs"

  config {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-project"
  }
}

