provider "google" {
  region  = "${var.region}"
  project = "${var.gcp-project}"
}

terraform {
  backend "gcs" {
    bucket = "tf-wescale-sandbox"
    prefix = "terraform/layer-data"
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
