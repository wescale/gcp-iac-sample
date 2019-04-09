# POC WeScale

## Prérequis

- Terraform v0.11
- Python 3.6
- Gcloud 
- kubectl

### Installation des dépendances Python

Aller dans le répertoire "iac", puis lancer la commande suivante:

```language-bash
pip install -r requirements.txt
```

## Structure du repository

Dans ce repository git vous trouverez la structure suivante:

- <b>"app"</b>: l'application simple en Go permettant de tester cette infrastructure et son outillage de CI/CD
    - <b>"src"</b>: code source de l'application
    - <b>"app-chart"</b>: chart Helm permettant de déploiement de l'application
    - <b>"static"</b>: une dépendance static de la stack à déployer
    - <b>"ci.sh"</b> et <b>"cd.sh"</b>: les scripts à lancer par l'usine
- <b>"docs"</b>: reprend la documentation explicative de ce POC et du workshop
- <b>"iac"</b>: le code pour la création de l'infrastructure (Terraform + Kubernetes)
    - <b>"kubernetes"</b>: installation des dépendances de Kubernetes
    - <b>"scripts"</b>: des scripts bash pour des besoins spécifiques
    - <b>"terraform"</b>: contient l'ensemble des layers Terraform
- <b>"plateform"</b>: un exemple de manifest d'une plateforme

## Architecture

![](docs/img/Architecture.png)

Quelques points importants de cette infrastructure:

- Kubernetes est dans un réseau privé pour les nodes et en public pour les masters. Voir [docs/gke](docs/gke.MD)
- le routeur NAT permet aux instances Kubernetes isolé dans un subnet "privé" et sans adresse IP publique de pouvoir atteindre des cibles réseaux sur Internet. (GCR, webservice extérieur, ...)
- le LoadBalancer doit ici être de type "HTTP" pour pouvoir acceter les appels gRPC voir [docs/http-loadbalanceur](docs/http-loadbalanceur.MD)
- l'instance Cloud SQL est gérée via un Peering voir [/docs/cloud-SQL](docs/cloud-SQL.MD)

## IaC

![](docs/img/IaC-schema.png)

Le principe de cette infrastructure est de décrire l'infrastructure dans un "manifest" en YAML.

C'est cette description qui permettra de configurer chaque plateforme en fonction des besoins.

Depuis ce layer l'IaC appel des layers Terraform. [Article sur les layers](https://blog.wescale.fr/2017/06/12/terraform-layering-pourquoi-et-comment/)

Les layer permettent de créer l'infrastructure Terraform. 

### Manifest

Le manifest décrit une platefome et permet d'appeler les éléments d'IaC à partir d'un fichier unique.

Pour aller plus loin avec le manifest: [docs/manifest.MD](docs/manifest.MD)

### layer-project

Ce layer est le seul à ne pas être exécuté à chaque création de plateforme.

Il permet d'activer les différents services GCP à la création d'un nouveau GCP Project.

### layer-base

Dans ce layer 

### layer-kubernetes

### layer-data

### Kubernetes dépendances

## Continuous Integration

![](docs/img/CI-schema.png)


## Continuous Delivery

![](docs/img/ContinuousDelivery-schema.png)

## Bonnes pratiques

## Reste à faire
