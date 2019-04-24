resource "google_service_account" "app_a" {
  account_id   = "application-a-${terraform.workspace}"
  display_name = "service account for app a"
}

resource "google_service_account_key" "app_a_key" {
  service_account_id = "${google_service_account.app_a.name}"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

// resource "google_service_account_iam_binding" "app_a_iam" {
//   service_account_id = "${google_service_account.app_a.name}"
//   role               = "roles/iam.serviceAccountKeys.get"


//   members = [
//     "serviceAccount:${google_service_account.app_a.email}",
//   ]
// }


// data "google_iam_policy" "app_a_policy" {
//   binding {
//     role = "roles/pubsub.subscriber"


//     members = [
//       "serviceAccount:${google_service_account.app_a.email}",
//     ]
//   }
// }


// resource "google_service_account_iam_policy" "app_a_iam" {
//   service_account_id = "${google_service_account.app_a.name}"
//   policy_data        = "${data.google_iam_policy.app_a_policy.policy_data}"
// }

