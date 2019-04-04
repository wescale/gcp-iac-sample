// list with "gcloud services list"
resource "google_project_services" "project" {
  project = "${var.gcp-project}"
  services   = [
        "container.googleapis.com", 
        "datastore.googleapis.com", 
        "pubsub.googleapis.com",
        "oslogin.googleapis.com",
        "cloudfunctions.googleapis.com",
        "compute.googleapis.com",
        "dns.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com",
        "servicenetworking.googleapis.com",
        "servicemanagement.googleapis.com",
        "serviceusage.googleapis.com",
        "sql-component.googleapis.com",
        "sqladmin.googleapis.com",
        "stackdriver.googleapis.com",
        "storage-api.googleapis.com",
        "storage-component.googleapis.com",
        "iamcredentials.googleapis.com",
        "iam.googleapis.com",
        "firebaserules.googleapis.com",
        "bigquery-json.googleapis.com",
        "containerregistry.googleapis.com"
    ]
}

