#!/usr/bin/env python

import yaml
from functions_iac import create_base, create_kubernetes, create_data, get_service_account, deploy_assets
from functions_k8s import connect_gke, create_namespace, get_secret, save_secrets, apply_kubernetes, deploy_helm
from utils_iac import randomString

name_file = raw_input("Nom du fichier: ")

with open("../plateform/manifests/"+name_file+".yaml", 'r') as stream:
    try:
        plateform=yaml.load(stream)
        print(plateform)

        print("Create plateform with name: " + plateform['name'])

        # print("Layer-project...")
        # create_project()
        
        print("Layer-base...")
        create_base(plateform)

        if "gke" in plateform['infrastructure']:
            print("Layer-kubernetes...")
            create_kubernetes(plateform)

            print("connect to new plateform...")
            connect_gke(plateform)

            for name in plateform['infrastructure']['namespaces']:
                create_namespace(name)
        else:
            print("Layer-kubernetes skip !")

        if 'cloudsql' in plateform['infrastructure']:
            print("Layer-data...")
            user1_password, user2_password = get_secret()
            print("user1_password:"+ user1_password)
            print("user2_password:"+ user2_password)

            update_yaml = False
            if 'instance-num' in plateform['infrastructure']['cloudsql']:
                print("use existing instance...")
                unique_id = plateform['infrastructure']['cloudsql']['instance-num']
            else:
                print("random string generate...")
                unique_id = randomString()
                update_yaml = True

            print("unique-id:"+ unique_id)
            create_data(plateform, user1_password, user2_password, unique_id)
            plateform['infrastructure']['cloudsql']['instance-num']=unique_id

            if update_yaml:
                with open("../plateform/manifests/"+name_file+".yaml", 'w') as yaml_file:
                    yaml.dump(plateform, yaml_file, default_flow_style=False)

            print("Save SQL secrets in kubernetes")
            sa_key = get_service_account()
            save_secrets(user1_password, user2_password, sa_key)

        else:
            print("Layer-data skip !")


        apply_kubernetes(plateform)

        print('Applications deployment:')
        if 'applications' in plateform:
            for app in plateform['applications']:
                print("Helm apply for " + app['name'] + ", version:" + app['version'])
                deploy_helm(app['name'], app['version'], app['namespace'])

        print('static assets:')
        deploy_assets(plateform['name'])

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)
