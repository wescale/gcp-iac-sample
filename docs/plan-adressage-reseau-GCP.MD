# Plan addressage réseau

## Limitation du découpage

Ce plan d'adressage a les limites suivantes:

- 4 régions GCP par plateforme
- 4096 pod par cluster Kubernetes
- 4096 services par cluster Kubernetes

## Prod

Réseau: 10.0.0.0/16

Region1:

- Kubernetes Master (master_ipv4_cidr_block): 10.0.0.0/28
- GCP subnet: 10.0.16.0/20
- Kubernetes Pod IP: 10.0.32.0/20
- Kubernetes Svc IP: 10.0.48.0/20

Region2:

- Kubernetes Master (master_ipv4_cidr_block): 10.0.0.16/28
- GCP subnet: 10.0.64.0/20
- Kubernetes Pod IP: 10.0.80.0/20
- Kubernetes Svc IP: 10.0.96.0/20

Region3:

- Kubernetes Master (master_ipv4_cidr_block): 10.0.0.32/28
- GCP subnet: 10.0.112.0/20
- Kubernetes Pod IP: 10.0.128.0/20
- Kubernetes Svc IP: 10.0.144.0/20

Region4:

- Kubernetes Master (master_ipv4_cidr_block): 10.0.0.48/28
- GCP subnet: 10.0.160.0/20
- Kubernetes Pod IP: 10.0.176.0/20
- Kubernetes Svc IP: 10.0.192.0/20

## UatPerf

Réseau: 10.1.0.0/16

Region1:

- Kubernetes Master (master_ipv4_cidr_block): 10.1.0.0/28
- GCP subnet: 10.1.16.0/20
- Kubernetes Pod IP: 10.1.32.0/20
- Kubernetes Svc IP: 10.1.48.0/20

Region2:

- Kubernetes Master (master_ipv4_cidr_block): 10.1.0.16/28
- GCP subnet: 10.1.64.0/20
- Kubernetes Pod IP: 10.1.80.0/20
- Kubernetes Svc IP: 10.1.96.0/20

Region3:

- Kubernetes Master (master_ipv4_cidr_block): 10.1.0.32/28
- GCP subnet: 10.1.112.0/20
- Kubernetes Pod IP: 10.1.128.0/20
- Kubernetes Svc IP: 10.1.144.0/20

Region4:

- Kubernetes Master (master_ipv4_cidr_block): 10.1.0.48/28
- GCP subnet: 10.1.160.0/20
- Kubernetes Pod IP: 10.1.176.0/20
- Kubernetes Svc IP: 10.1.192.0/20

## dev-1

Réseau: 10.10.0.0/16

Region1:

- Kubernetes Master (master_ipv4_cidr_block): 10.10.0.0/28
- GCP subnet: 10.10.16.0/20
- Kubernetes Pod IP: 10.10.32.0/20
- Kubernetes Svc IP: 10.10.48.0/20

Region2:

- Kubernetes Master (master_ipv4_cidr_block): 10.10.0.16/28
- GCP subnet: 10.10.64.0/20
- Kubernetes Pod IP: 10.10.80.0/20
- Kubernetes Svc IP: 10.10.96.0/20

Region3:

- Kubernetes Master (master_ipv4_cidr_block): 10.10.0.32/28
- GCP subnet: 10.10.112.0/20
- Kubernetes Pod IP: 10.10.128.0/20
- Kubernetes Svc IP: 10.10.144.0/20

Region4:

- Kubernetes Master (master_ipv4_cidr_block): 10.10.0.48/28
- GCP subnet: 10.10.160.0/20
- Kubernetes Pod IP: 10.10.176.0/20
- Kubernetes Svc IP: 10.10.192.0/20

## dev-2

Réseau: 10.11.0.0/16

Region1:

- Kubernetes Master (master_ipv4_cidr_block): 10.11.0.0/28
- GCP subnet: 10.11.16.0/20
- Kubernetes Pod IP: 10.11.32.0/20
- Kubernetes Svc IP: 10.11.48.0/20

Region2:

- Kubernetes Master (master_ipv4_cidr_block): 10.11.0.16/28
- GCP subnet: 10.11.64.0/20
- Kubernetes Pod IP: 10.11.80.0/20
- Kubernetes Svc IP: 10.11.96.0/20

Region3:

- Kubernetes Master (master_ipv4_cidr_block): 10.11.0.32/28
- GCP subnet: 10.11.112.0/20
- Kubernetes Pod IP: 10.11.128.0/20
- Kubernetes Svc IP: 10.11.144.0/20

Region4:

- Kubernetes Master (master_ipv4_cidr_block): 10.11.0.48/28
- GCP subnet: 10.11.160.0/20
- Kubernetes Pod IP: 10.11.176.0/20
- Kubernetes Svc IP: 10.11.192.0/20

## autres

Pour chaque plateforme à ajouter, incrémenter le deuxième chiffre de 1 (par exemple de 10.0.*.* à 10.1.*.*)
