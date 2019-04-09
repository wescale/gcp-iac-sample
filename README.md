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

### Les layers Terraform

Depuis ce layer l'IaC appel des layers Terraform. [Article sur les layers](https://blog.wescale.fr/2017/06/12/terraform-layering-pourquoi-et-comment/)

Les layer permettent de créer l'infrastructure dans GCP.

Chaque layer a un certain nombre d'entrées via des variables ou la possibilité de récupérer les variables de sortie des autres layers.

Chaque layer met à disposition des variables pour d'autres layer ou pour être récupérer via un script.

### Les workspaces Terraform

C'est l'outils de parralélisation des plateformes. Pour chaque plateforme correspond un workspace Terraform.
La création d'un workspace nous met à disposition:

- une variable ${terraform.workspace} permettant de suffixer les objets GCP
- la gestion d'un tfstate par workspace dans le backend de stockage des layers (ici GCS)

### Manifest

Le manifest décrit une platefome et permet d'appeler les éléments d'IaC à partir d'un fichier unique.

Pour aller plus loin avec le manifest: [docs/manifest.MD](docs/manifest.MD)

### layer-project

Ce layer est le seul à ne pas être exécuté à chaque création de plateforme.

Il permet d'activer les différents services GCP à la création d'un nouveau GCP Project.

### layer-base

Dans ce layer les éléments suivants sont créés:

- VPC
- Subnet
- Router NAT
- Private DNS 
- Peering vers "servicenetworking.googleapis.com" pour CloudSQL
- Service account

### layer-kubernetes

Dans ce layer les éléments suivants sont créés:

- Kubernetes via Google Kubernetes Engine voir [docs/gke](docs/gke.MD)
- LoadBalanceur HTTP voir [docs/http-loadbalanceur](docs/http-loadbalanceur.MD)
- Bucket dans GCS pour les fichiers statiques de l'application

### layer-data

Dans ce layer les éléments suivants sont créés:

- PubSub Topic
- PubSub Subscription
- CloudSQL
- Création d'un Record DNS dans la zone privé DNS de GCP

Attention: l'utilisation de CloudSQL nécessite la génération d 'un numéro unique pour la BDD. Il faut que le job de création d'infrastructure puisse commiter & pusher le manifest dans son repos.

### Kubernetes dépendances

Pour Kubernetes il faut installer:

- Helm (Tiller) pour l'installation d'applications
- CertManager pour la gestion des certificats

## Continuous Integration

![](docs/img/CI-schema.png)

Le schéma final avec l'ensemble des étapes du pipeline de Build.
Quelques explications ci dessous qui décrive ce fichier [app/ci.sh](app/ci.sh)

### tests

Les tests ne faisaient pas partie du périmètre de ce POC. 
Il faudra les ajouter par la suite.

Un test à minima qui peut être mis en place pour tester le packaging Helm est l'exécution de ces commandes.

```language-bash
helm install --dry-run --debug ./app/app-chart
helm lint ./app/app-chart
```

### compilation

```language-bash
docker build -t eu.gcr.io/livingpackets-sandbox/app:$version ./app/src/
```

### envoie dans GCR

```language-bash
docker push eu.gcr.io/livingpackets-sandbox/app:$version
```

### packaging Helm

```language-bash
helm package --version $version ./app/app-chart
gsutil mv app-chart-$version.tgz gs://charts-wescale-sandbox/app-chart/$version/app-chart-$version.tgz
```

## Continuous Delivery

![](docs/img/ContinuousDelivery-schema.png)

L'objectif de cette étape est de déployer une application dans une plateforme.

Pour cela il est possible d'utiliser:

- l'update de la plateform via le manifest et le job Jenkins générique
- un job dédié à cette fonction et qui peut exécuter le script [app/cd.sh](app/cd.sh)

### upgrade via Helm

Il faut commencer par télécharger le Chart depuis GCS puis mettre à jour.

```language-bash
gsutil cp gs://charts-wescale-sandbox/app-chart/$version/app-chart-$version.tgz app-chart-$version.tgz 
helm upgrade test-app app-chart-$version.tgz --set image.tag=$version
```

Il est également possible d'utiliser un outil de type ["Keel"](https://keel.sh/) pour mettre en place cette étape.

### déploiement des statics

```language-bash
gsutil cp static/LP-Box.svg gs://lp-static-bucket-dev-seb/image.svg
```

## Continuous Deployment

Le pipeline de continous deployment ne fait pas partie de ce POC.

Pour avoir une bonne vision sur la release, il faut réaliser les étapes suivantes:

- tests d'intégration
- tests de performances
- pen tests

chacun de ces tests doit archiver ses résultats dans le repertoire GCS utilisé par le pipeline de CI.

Avant un passage en production le release manager doit comparer le résultat de tout ces tests pour prendre une décision.
Des scripts peuvent être mis en place pour aider à la prise de décision. (comparaison release précédent/après)

## Reste à faire

- CloudFunction
- CloudSQL de prod avec résilience
- Monitoring des plateformes
- installation de CertManager
- déploiement des applications lors de l'application du manifeste
- dans le script de CD, tester si le package est installé avant de faire l'upgrade
- variabilisation du type d'instance SQL dans le manifeste
- deploiement app test via Python
