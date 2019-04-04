resource "google_sql_database_instance" "lp-instance-sql" {
  name             = "lp-instance-sql-${terraform.workspace}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${data.terraform_remote_state.layer-base.lp-cloud-services}"
    }
  }
}

resource "google_sql_user" "lb-sql-user1" {
  name     = "user1-${terraform.workspace}"
  instance = "${google_sql_database_instance.lp-instance-sql.name}"
  password = "testme"
}

resource "google_sql_user" "lb-sql-user2" {
  name     = "user2-${terraform.workspace}"
  instance = "${google_sql_database_instance.lp-instance-sql.name}"
  password = "testme"
}
