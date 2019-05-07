resource "google_compute_security_policy" "lp-policy-ip-restriction" {
  name = "lp-policy-ip-restriction-${terraform.workspace}"

  rule {
    action   = "deny(403)"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Deny all IPs"
  }

  rule {
    action   = "allow"
    priority = "1000"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["${var.allowed-ips}"]
      }
    }

    description = "Allowed ips"
  }
}
