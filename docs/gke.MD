# Google Kubernetes Engine

## Installation

Il est possible de créer un cluster via la resource Terraform suivante.

Ici l'objectif est de créer un cluster privé sans NodePool associé puis d'associer un NodePool.

```language-terraform
resource "google_container_cluster" "lp-cluster" {
  provider = "google-beta"
  name     = "lp-cluster-${terraform.workspace}"
  location = "${var.region}"

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "192.168.16.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${var.myip}"
      display_name = "dyn"
    }

    cidr_blocks {
      cidr_block   = "81.250.133.68/32"
      display_name = "WeScale"
    }
  }

  min_master_version = "${var.k8s-version}"
  node_version       = "${var.k8s-version}"

  network    = "${data.terraform_remote_state.layer-base.lp-network}"
  subnetwork = "${data.terraform_remote_state.layer-base.lp-sub-network}"

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${data.terraform_remote_state.layer-base.pod-net-name}"
    services_secondary_range_name = "${data.terraform_remote_state.layer-base.svc-net-name}"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}
```

Création du NodePool par défaut.

```language-terraform
resource "google_container_node_pool" "np-default" {
  provider   = "google-beta"
  name       = "np-default-${terraform.workspace}"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.lp-cluster.name}"
  node_count = 1

  node_config {
    machine_type = "${var.instance-type}"
    preemptible  = "${var.preemptible}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      Name      = "lp-cluster"
      Plateform = "${terraform.workspace}"
    }

    tags = ["kubernetes", "lp-cluster-${terraform.workspace}"]
  }
}
```

## Connexion

Pour obtenir les credentials, il faut lancer la commande gcloud suivante:

```language-bash
gcloud beta container clusters get-credentials lp-cluster-$workspace \
    --region $region \
    --project $GCP_PROJECT
```

Pour obtenir les droits administrateurs (si l'utilisateur a le rôle role/containers.admin dans IAM)

```language-bash
username=$(gcloud config get-value account)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$username
```
