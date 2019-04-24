variable "gcp-project" {
  default = "slavayssiere-sandbox"
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

variable "min_node" {
  default = 3
}

variable "max_node" {
  default = 10
}

variable "range_ip_master" {}
