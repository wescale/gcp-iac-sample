# LB HTTP

## Les différents objets

## Interface

Création d'une IP publique globale pour le LB.

```language-terraform
resource "google_compute_global_address" "lb-public-ip" {
  name = "lb-public-ip-${terraform.workspace}"
}
```

Création du loadbalanceur. Liaison avec l'IP publique réservé et lien avec la target.

```language-terraform
resource "google_compute_global_forwarding_rule" "lp-public-lb-http" {
  name       = "lp-public-lb-http-${terraform.workspace}"
  target     = "${google_compute_target_http_proxy.lp-k8s-pool.self_link}"
  ip_address = "${google_compute_global_address.lb-public-ip.self_link}"
  port_range = "80"
}
```

## Table de routage

Définition de la table de routage HTTP / DNS du LB HTTP.

Ici :

- par défaut les messages sont envoyés à la gateway publique
- les messages arrivant sur "lp.com" vers la gateway publique
- les messages arrivant sur "/admin" ou en "admin.lp.com" vers la gateway du BO.

```language-terraform
resource "google_compute_url_map" "lb-urlmap" {
  name        = "lb-urlmap-${terraform.workspace}"
  description = "a description"

  default_service = "${google_compute_backend_service.lp-public-home.self_link}"

  host_rule {
    hosts        = ["lp.com"]
    path_matcher = "publicpaths"
  }
  
  host_rule {
    hosts        = ["admin.lp.com"]
    path_matcher = "bopaths"
  }

  path_matcher {
    name            = "publicpaths"
    default_service = "${google_compute_backend_service.lp-public-home.self_link}"

    path_rule {
      paths   = ["/static"]
      service = "${google_compute_backend_bucket.lp-static.self_link}"
    }
  }

  path_matcher {
    name            = "bopaths"
    default_service = "${google_compute_backend_service.lp-bo-home.self_link}"

    path_rule {
      paths   = ["/static"]
      service = "${google_compute_backend_bucket.lp-bo-static.self_link}"
    }
  }
}
```

## Cibles du LB

Ici on fait le lien entre le LB et la table de routage

```language-terraform
resource "google_compute_target_http_proxy" "lp-k8s-pool" {
  name    = "lp-k8s-pool-${terraform.workspace}"
  url_map = "${google_compute_url_map.lb-urlmap.self_link}"
}
```

Dans le cadre d'un LB HTTP il faut définir un contrôle d'état.
Dans ce cas on expose un service "test" sur un NodePort définit à 32080. 

```language-terraform
resource "google_compute_http_health_check" "lp-k8s-hc" {
  name               = "lp-k8s-hc-${terraform.workspace}"
  request_path       = "/healthz"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = 32080
}
```

Un backend de service. Ici il s'agit de notre application "test" disponible via notre NodePort.
Il faut associer un ensemble de node. Ici le NodePool créé par défaut.

```language-terraform
resource "google_compute_backend_service" "lp-public-home" {
  name        = "lp-public-home-${terraform.workspace}"
  description = "Our company website"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  // activer ce backend dans le cas où on utilise le NodePool par défaut du cluster
  //   backend {
  //     group = "${replace(element(google_container_cluster.lp-cluster.instance_group_urls, 1), "Manager", "")}"
  //   }

  backend {
    group = "${replace(element(google_container_node_pool.np-default.instance_group_urls, 1), "Manager", "")}"
  }
  health_checks = ["${google_compute_http_health_check.lp-k8s-hc.self_link}"]
}
```

Dans le cadre des fichiers static il faut définir un backend configuré avec le bucket GCS correspondant.

```language-terraform
resource "google_compute_backend_bucket" "lp-static" {
  name        = "lp-static-${terraform.workspace}"
  description = "Contains beautiful images"
  bucket_name = "${google_storage_bucket.lp-static-bucket.name}"
  enable_cdn  = false
}
```

## Post script

Cas particulier non pris en charge par Terraform, il faut attribuer un "nom" au port des instances GCE utilisés par GKE pour pouvoir faire le HealthCheck du LB HTTP.

C'est l'objectif de ce script: [iac/terraform/layer-kubernetes/apply_post.sh](iac/terraform/layer-kubernetes/apply_post.sh)

On commence par obtenir la liste des groupes d'instances.

```language-bash
ig=$(gcloud compute instance-groups list --project livingpackets-sandbox --project $GCP_PROJECT | grep np-default | cut -d ' ' -f1)
```

Pour chacune des instances groupes on utilise une commande gcloud pour nommer le port.

```language-bash
for...
do
    gcloud compute instance-groups set-named-ports $i --named-ports=http:32080 --project $GCP_PROJECT --zone ${az_array[$it]}
done 
```
