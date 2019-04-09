# Bonnes pratiques

## Deployment Best Practice

Un article du blog permet de mieux comprendre les bonnes pratiques d'écriture des "Deployement", vous le trouverez [ici](https://blog.wescale.fr/2018/08/16/kubernetes-comment-ecrire-un-deployment/)

### Gestion des affinités

Les affinités dans Kubernetes permettent de mieux répartir la charge et d’assurer une meilleure disponibilité.
En effet on peut demander au `Scheduler` que nos `pods` soit dans une zone de disponibilité différente (Availability zone).
On peut aussi faire en sorte que nos pods soit répartie sur des `nodes` différents.

### HorizontalPodAutoscaler

Pour obtenir un dimensionnement des différentes applications, il faudra ajouter à chaque Deployment un HorizontalPodAutoscaler. 
Il sera en charge d’augmenter et de diminuer le nombre de réplicas de Pod en pilotant le Deployment.

Il est possible de dimensionner sur des contraintes classiques de “compute” comme le CPU ou la RAM ou  d’utiliser des métriques personnalisées issue de Prometheus.

### PodDisruptionBudget

A définir pour chaque application - donc à chaque Deployment - cet objet va permettre de définir les limites hautes et basses de Pods disponible ou indisponible pendant une opération d’administration: RollingUpdate ou suppression d’un Node par exemple.

### NetworkPolicy

Les NetworkPolicy permettent de gérer les droits d’ouverture de connexion vers les autres Pods, les autre namespace et les connexions extérieurs sortantes et entrantes.

## Namespaced object

Certains objets permettent de gérer les paramètres des namespaces

### ResourceQuota

Cet objet permet de définir les ressources minimum et maximum par défaut de chaque namespace et donc de jouer sur la qualité de service entre applications.
Ainsi il va être possible de définir des contraintes sur:

- le compute: CPU, RAM,...
- le stockage
- le nombre d’objets Kubernetes dans le namespace

### LimitRange

Cet objet va définir des contraintes d’utilisation des ressources de type “Compute” par Pod ou par conteneur au sein des Pods.

### PodSecurityPolicy

Cet objet limite les droits qu’un utilisateur peut donner à un Pod. Il peut permettre de limiter également l’accès à certains types de driver de volume ou limiter la plage de ports utilisable.
