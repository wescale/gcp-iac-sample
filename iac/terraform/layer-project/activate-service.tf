// list with "gcloud services list"
resource "google_project_services" "project" {
  project = "${var.gcp-project}"

  services = [
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
    "containerregistry.googleapis.com",
  ]
}

// services.1047978806: "firebase.googleapis.com" => ""
// services.1114535314: "firebasedynamiclinks.googleapis.com" => ""
// services.1146472476: "firebaserules.googleapis.com" => "firebaserules.googleapis.com"
// services.1237822282: "firebaseremoteconfig.googleapis.com" => ""
// services.133405307:  "storage-component.googleapis.com" => "storage-component.googleapis.com"
// services.138520988:  "testing.googleapis.com" => ""
// services.1560437671: "iam.googleapis.com" => "iam.googleapis.com"
// services.1568433289: "oslogin.googleapis.com" => "oslogin.googleapis.com"
// services.1610229196: "bigquery-json.googleapis.com" => "bigquery-json.googleapis.com"
// services.1633256984: "appengine.googleapis.com" => ""
// services.1709105136: "googlecloudmessaging.googleapis.com" => ""
// services.1712537408: "containerregistry.googleapis.com" => "containerregistry.googleapis.com"
// services.1793140363: "clouddebugger.googleapis.com" => ""
// services.1904024597: "runtimeconfig.googleapis.com" => ""
// services.1954675454: "serviceusage.googleapis.com" => "serviceusage.googleapis.com"
// services.2117420113: "pubsub.googleapis.com" => "pubsub.googleapis.com"
// services.2134988552: "fcm.googleapis.com" => ""
// services.2240314979: "compute.googleapis.com" => "compute.googleapis.com"
// services.238136042:  "cloudapis.googleapis.com" => ""
// services.2384399059: "firestore.googleapis.com" => ""
// services.2388244550: "identitytoolkit.googleapis.com" => ""
// services.2455649047: "servicenetworking.googleapis.com" => "servicenetworking.googleapis.com"
// services.2471815660: "servicemanagement.googleapis.com" => "servicemanagement.googleapis.com"
// services.2631575801: "sqladmin.googleapis.com" => "sqladmin.googleapis.com"
// services.2928564140: "dns.googleapis.com" => "dns.googleapis.com"
// services.323125032:  "cloudtrace.googleapis.com" => ""
// services.3237295688: "monitoring.googleapis.com" => "monitoring.googleapis.com"
// services.3327360159: "stackdriver.googleapis.com" => "stackdriver.googleapis.com"
// services.335057082:  "securetoken.googleapis.com" => ""
// services.3355193353: "logging.googleapis.com" => "logging.googleapis.com"
// services.3604209692: "iamcredentials.googleapis.com" => "iamcredentials.googleapis.com"
// services.3644083179: "cloudresourcemanager.googleapis.com" => ""
// services.3740470850: "container.googleapis.com" => "container.googleapis.com"
// services.3875785048: "storage-api.googleapis.com" => "storage-api.googleapis.com"
// services.3899772697: "cloudfunctions.googleapis.com" => "cloudfunctions.googleapis.com"
// services.4049550518: "firebasehosting.googleapis.com" => ""
// services.77316126:   "sql-component.googleapis.com" => "sql-component.googleapis.com"
// services.932568001:  "datastore.googleapis.com" => "datastore.googleapis.com"

