variable "gcp-project" {
  default = "slavayssiere-sandbox"
}

variable "region" {
  default = "europe-west3"
}

variable "database_version" {
  default = "MYSQL_5_6"
}

variable "app_password" {}

variable "admin_password" {}

variable "unique_id" {}

variable "env" {
  default = "dev"
}

variable "database_instance_type" {
  default = "db-f1-micro"
}

variable "database_disk_size" {
  default = 20
}
