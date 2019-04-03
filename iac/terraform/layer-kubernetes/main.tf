provider "google" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

provider "google-beta" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

variable "gcp-project" {
  default = "livingpackets-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "myip" {}

terraform {
  backend "gcs" {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-kubernetes"
  }
}

data "terraform_remote_state" "layer-project" {
  backend = "gcs"

  config {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-project"
  }
}

data "terraform_remote_state" "layer-base" {
  backend = "gcs"

  config {
    bucket = "tf-wescale-sandbox"
    path   = "terraform/layer-base/${terraform.workspace}.tfstate"
  }
}
