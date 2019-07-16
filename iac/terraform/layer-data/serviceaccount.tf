resource "google_service_account" "firestore_viewer" {
  account_id   = "firestore-viewer-${terraform.workspace}"
  display_name = "Firestore for viewers"
}

resource "google_project_iam_binding" "firestore-view-account-iam" {
  role = "roles/datastore.user"

  members = [
    "serviceAccount:${google_service_account.firestore_viewer.email}",
  ]
}

// resource "google_project_iam_binding" "firestore-sa-workload-identity" {
//   role = "roles/iam.workloadIdentityUser"

//   members = [
//     "serviceAccount:${var.gcp-project}.svc.id.goog[webservices/firestore-viewer]",
//   ]
// }

resource "google_service_account_iam_member" "allow-user-workload-identity" {
  service_account_id = "${google_service_account.firestore_viewer.name}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp-project}.svc.id.goog[webservices/firestore-viewer]"
}
