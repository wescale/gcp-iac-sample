# Cloud SQL

L'objectif est de mettre en place une instance SQL (MySQL ici) dans une zone réseau privé, donc non accessible directement depuis internet.
C'est une bonne pratique de sécurité et cela simplifie et accélère la connexion entre les containeurs et leur base de donnée.

## Réseau GCP

Création d'une IP interne pour la mise en place d'un peering avec le réseau GCP.

```language-terraform
resource "google_compute_global_address" ... {
  provider      = "google-beta"
  name          = "lp-cloud-private-ip-${terraform.workspace}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.lp-net.self_link}"
}
```

Mise en place d'un peering vers le service de Google.

```language-terraform
resource "google_service_networking_connection" "lp-cloud-peering" {
  provider                = "google-beta"
  network                 = "${google_compute_network.lp-net.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.lp-cloud-private-ip.name}"]
}
```

## Installation

Dans le cadre de la gestion de ce service managé, Google réserve le nom des instances pendant 2 mois.

Comme l'objectif est de faire des environnements éphémères nous devons donc générer un suffix pour pouvoir regénérer notre plateforme.

Cet identifiant unique est ensuite stocké dans le manifest.

```language-terraform
resource "google_sql_database_instance" "lp-instance-sql" {
  name             = "lp-instance-sql-${terraform.workspace}-${var.unique_id}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${data.terraform_remote_state.layer-base.lp-network-self-link}"
    }
  }
}
```

## Gestion des bases et users

Pour créer un utilisateur avec des droits "admin".

Attention, il ne faut pas créer d'utilisateur applicatif avec cette méthode ou au moins modifier leur droit par la suite pour limiter l'accès à la BDD.

```language-terraform
resource "google_sql_user" "lb-sql-user2" {
  depends_on = ["google_sql_database_instance.lp-instance-sql"]

  name     = "user2-${terraform.workspace}"
  instance = "lp-instance-sql-${terraform.workspace}-${var.unique_id}"
  password = "${var.user2_password}"
  host     = "%"
}
```

Ici la création d'une database au sein de l'instance.

```language-terraform
resource "google_sql_database" "lp-sql-database" {
  depends_on = ["google_sql_database_instance.lp-instance-sql"]

  name      = "my-database"
  instance  = "lp-instance-sql-${terraform.workspace}-${var.unique_id}"
  charset   = "utf8"
  collation = "utf8_general_ci"
}
```

## Installation des secrets dans Kubernetes

Les secrets sont générés dans le script Python puis stockés dans Kubernetes

```language-python
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="nom-du-secret"))
    body.data = {
        "user": base64.b64encode("username"), 
        "password": base64.b64encode("password")
    }
    body.type = "Opaque"
    try:
        api_response = api_instance.create_namespaced_secret(body=body, namespace='namespace-du-secret')
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e)
        if e.status == 409:
            print("secret already exist")
        else:
            print("%s\n" % e)
```

Utilisation dans un POD.

```language-yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
  namespace: namespace-du-secret
spec:
  containers:
  - name: mycontainer
    image: ...
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: nom-du-secret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: nom-du-secret
            key: password
```
