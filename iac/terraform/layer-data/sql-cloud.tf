resource "google_sql_database_instance" "lp-instance-sql" {
  name             = "lp-instance-sql-${terraform.workspace}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${data.terraform_remote_state.layer-base.lp-network}"
    }
  }
}

resource "google_sql_user" "lb-sql-user1" {
  name     = "user1-${terraform.workspace}"
  instance = "${google_sql_database_instance.lp-instance-sql.name}"
  password = "${var.user1_password}"
  host = "%"
}

resource "google_sql_user" "lb-sql-user2" {
  name     = "user2-${terraform.workspace}"
  instance = "${google_sql_database_instance.lp-instance-sql.name}"
  password = "${var.user2_password}"
  host = "%"
}

resource "google_sql_database" "lp-sql-database" {
  name      = "my-database"
  instance  = "${google_sql_database_instance.lp-instance-sql.name}"
  charset   = "utf8"
  collation = "utf8_general_ci"
}
