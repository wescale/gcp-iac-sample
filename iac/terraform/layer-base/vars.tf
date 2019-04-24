variable "gcp-project" {
  default = "slavayssiere-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "pod-net-name" {
  default = "c0-pods"
}

variable "svc-net-name" {
  default = "c0-services"
}

variable "range-ip" {
  default = "192.168.0.0/20"
}

variable "range-ip-pod" {
  default = "10.0.0.0/16"
}

variable "range-ip-svc" {
  default = "10.1.0.0/16"
}

variable "range-plateform" {}
