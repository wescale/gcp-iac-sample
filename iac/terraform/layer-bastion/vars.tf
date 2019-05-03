variable "gcp-project" {
  default = "slavayssiere-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "instance_type" {
  default = "n1-standard-1"
}

variable "instance_image" {
  default = "debian-cloud/debian-9"
}

variable "preemptible" {
  default = "false"
}
