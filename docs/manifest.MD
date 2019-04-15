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
  - le namespace de l'application
  - la version à déployer
  - le lien vers la documentation dynamique

Ce manifest a pour objectif de suivre le développement, il est amener à évoluer en même temps que l'IaC et l'architecture applicative.

Par exemple indiquer des dépendances entre applications, des variables d'environnement communes via des ConfigMap.

## Exemple

voir à la racine de ce repository: plateform/manifests/dev-2.yaml
