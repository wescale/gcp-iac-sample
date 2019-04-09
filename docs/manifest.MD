# Plateform manifest 

## Plan du manifeste

Il existe plusieurs partie dans le manifeste:

- information général sur la plateforme (nom, région, GCP Project,...)
- une partie infrastructure utilisé par l'IaC
  - information général sur l'IaC (version du code compatible avec le manifest, ...)
  - plan d'adressage réseau
  - cloudsql
  - gke
  - dépendances Kubernetes
  - creation des namespaces kubernetes
- déploiement des applications avec pour chacune:
  - son nom
  - la version à déployer
  - le lien vers la documentation dynamique

Ce manifest a pour objectif de suivre le développement, il est amener à évoluer en même temps que l'IaC et l'architecture applicative.

Par exemple indiquer des dépendances entre applications, des variables d'environnement communes via des ConfigMap.

## Exemple complet

```language-yaml
name: dev-3
gcp-project: livingpackets-sandbox
region: europe-west3
type: dev
infrastructure:
  range-ip: 192.168.0.0/20
  range-ip-pod: 10.0.0.0/16
  range-ip-svc: 10.1.0.0/16
  version: 0.0.1
  cloudsql:
    version: MYSQL_5_7
  gke:
    instance-type: n1-standard-1
    ips_whitelist:
    - 37.173.210.210/32
    max: 30
    min: 3
    preemptible: true
    version: 1.12
  dependancies:
    certmanager:
      enabled: true
      version: x
  namespaces:
  - gateways
  - webservices
  - monitoring
applications:
- documentation: http://swagger.io
  name: app_a
  version: 1.0.4
- documentation: http://swagger.io
  name: app_a
  version: 2.0.3
- documentation: http://swagger.io
  name: app_b
  version: 0.0.3
```