# Plateform manifest 

## Exemple

```language-yaml
name: dev-3
gcp-project: livingpackets-sandbox
region: europe-west3
type: dev
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
infrastructure:
  cloudsql:
    version: MYSQL_5_7
  dependancies:
    certmanager:
      enabled: true
      version: x
  gke:
    instance-type: n1-standard-1
    ips_whitelist:
    - 37.173.210.210/32
    max: 30
    min: 3
    preemptible: true
    version: 1.12
  namespaces:
  - gateways
  - webservices
  - monitoring
  range-ip: 192.168.0.0/20
  range-ip-pod: 10.0.0.0/16
  range-ip-svc: 10.1.0.0/16
  version: 0.0.1
```