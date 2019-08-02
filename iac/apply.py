#!/usr/bin/env python

import yaml
from functions_iac import create_base, create_kubernetes, create_data, deploy_assets, create_bastion
from functions_k8s import connect_gke, create_namespace, get_secret, save_secrets, apply_kubernetes, deploy_helm, wait_cluster_if_exist, install_prometheus_operator, install_consul, install_traefik, deploy_yaml
from utils_iac import randomString
import sys

if len(sys.argv) > 1:
    name_file = sys.argv[1]
    print("create from file: ../plateform/manifests/"+name_file+".yaml")
else:
    name_file = raw_input("Nom du fichier: ")

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

with open("../plateform/manifests/"+name_file+".yaml", 'r') as stream:
    try:
        plateform=yaml.load(stream, Loader=Loader)
        print(plateform)

        print("Create plateform with name: " + plateform['name'])

        print("Layer-base...")
        create_base(plateform)

        # Attention: "bastion" doit etre avant Kubernetes
        if "bastion" in plateform['infrastructure']:
            print("Layer-bastion...")
            create_bastion(plateform)
        
        if "gke" in plateform['infrastructure']:
            wait_cluster_if_exist(plateform)

            print("Layer-kubernetes...")
            create_kubernetes(plateform)

            print("connect to new plateform...")
            wait_cluster_if_exist(plateform)
            connect_gke(plateform)

            for name in plateform['infrastructure']['namespaces']:
                create_namespace(name)
        else:
            print("Layer-kubernetes skip !")


        if 'cloudsql' in plateform['infrastructure']:
            print("Layer-data...")
            admin_password, app_password = get_secret()
            print("admin_password:"+ admin_password.decode("utf-8"))
            print("app_password:"+ app_password.decode("utf-8") )

            print("Save SQL secrets in kubernetes")
            save_secrets(admin_password, app_password, plateform['name'])

            update_yaml = False
            if 'instance-num' in plateform['infrastructure']['cloudsql']:
                print("use existing instance...")
                unique_id = plateform['infrastructure']['cloudsql']['instance-num']
            else:
                print("random string generate...")
                unique_id = randomString()
                update_yaml = True

            print("unique-id:"+ unique_id)
            create_data(plateform, admin_password, app_password, unique_id)
            plateform['infrastructure']['cloudsql']['instance-num']=unique_id

            if update_yaml:
                with open("../plateform/manifests/"+name_file+".yaml", 'w') as yaml_file:
                    yaml.dump(plateform, yaml_file, default_flow_style=False)


        else:
            print("Layer-data skip !")

        # apply kubernetes
        apply_kubernetes(plateform['name'])

        install_consul(plateform['name'], plateform['infrastructure']['dependancies']['consul']['version'])
        install_traefik(plateform['name'], plateform['infrastructure']['dependancies']['ingress-controller']['chart-version'], plateform['infrastructure']['dependancies']['ingress-controller']['version'])

        print('Applications deployment:')
        if 'applications' in plateform:
            admin_password, app_password = get_secret()
            for app in plateform['applications']:
                if 'version' in app:
                    print("Helm apply for " + app['name'] + ", version:" + app['version'])
                    deploy_helm(app['name'], app['version'], app['namespace'])
                else:
                    try:
                        deploy_yaml(plateform['name'], app, admin_password)
                    except:
                        print("app deployment error")

        print('static assets:')
        deploy_assets(plateform['name'])

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)
