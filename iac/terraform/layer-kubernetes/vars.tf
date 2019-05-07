variable "gcp-project" {
  default = "slavayssiere-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "white-ip-1" {
  default = "81.250.133.68/32"
}

variable "white-ip-2" {
  default = "81.250.133.68/32"
}

variable "white-ip-3" {
  default = "81.250.133.68/32"
}

variable "white-ip-4" {
  default = "81.250.133.68/32"
}

variable "white-ip-5" {
  default = "81.250.133.68/32"
}

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

data "google_compute_lb_ip_ranges" "ranges" {}
