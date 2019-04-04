
variable "gcp-project" {
  default = "livingpackets-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "myip" {}

variable "k8s-version" {
  default = "1.12.5-gke.5"
}

variable "preemptible" {
  default = false
}

variable "instance-type" {
  default = "n1-standard-1"
}
