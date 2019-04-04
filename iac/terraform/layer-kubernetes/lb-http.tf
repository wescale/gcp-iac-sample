resource "google_compute_global_address" "lb-public-ip" {
  name = "lb-public-ip-${terraform.workspace}"
}

resource "google_compute_global_forwarding_rule" "lp-public-lb-http" {
  name       = "lp-public-lb-http-${terraform.workspace}"
  target     = "${google_compute_target_http_proxy.lp-k8s-pool.self_link}"
  ip_address = "${google_compute_global_address.lb-public-ip.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "lp-k8s-pool" {
  name    = "lp-k8s-pool-${terraform.workspace}"
  url_map = "${google_compute_url_map.lb-urlmap.self_link}"
}

resource "google_compute_http_health_check" "lp-k8s-hc" {
  name               = "lp-k8s-hc-${terraform.workspace}"
  request_path       = "/healthz"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = 32080
}

resource "google_compute_url_map" "lb-urlmap" {
  name        = "lb-urlmap-${terraform.workspace}"
  description = "a description"

  default_service = "${google_compute_backend_service.lp-public-home.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.lp-public-home.self_link}"

    path_rule {
      paths   = ["/static"]
      service = "${google_compute_backend_bucket.lp-static.self_link}"
    }
  }
}

resource "google_compute_backend_service" "lp-public-home" {
  name        = "lp-public-home-${terraform.workspace}"
  description = "Our company website"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  //   backend {
  //     group = "${replace(element(google_container_cluster.lp-cluster.instance_group_urls, 1), "Manager", "")}"
  //   }

  backend {
    group = "${replace(element(google_container_node_pool.np-default.instance_group_urls, 1), "Manager", "")}"
  }
  health_checks = ["${google_compute_http_health_check.lp-k8s-hc.self_link}"]
}

resource "google_compute_backend_bucket" "lp-static" {
  name        = "lp-static-${terraform.workspace}"
  description = "Contains beautiful images"
  bucket_name = "${google_storage_bucket.lp-static-bucket.name}"
  enable_cdn  = false
}

resource "google_storage_bucket" "lp-static-bucket" {
  name          = "lp-static-bucket-${terraform.workspace}"
  location      = "${var.region}"
  force_destroy = true
}
