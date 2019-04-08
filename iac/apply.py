#!/usr/bin/env python

import yaml
from python_terraform import *
from functions_iac import *
from functions_k8s import *
from utils_iac import randomString

name = raw_input("Nom du fichier: ")

with open("../plateform/manifests/"+name+".yaml", 'r') as stream:
    try:
        plateform=yaml.load(stream)
        print(plateform)

        print("Create plateform with name: " + plateform['name'])

        # print("Layer-project...")
        # create_project()
        
        print("Layer-base...")
        create_base(plateform)

        print("Layer-kubernetes...")
        create_kubernetes(plateform)

        print("connect to new plateform...")
        connect_gke(plateform)

        print("Layer-data...")
        user1_password, user2_password = get_secret()
        print("user1_password:"+ user1_password)
        print("user2_password:"+ user2_password)
        if 'instance-num' in plateform['infrastructure']['cloudsql']:
            print("use existing instance...")
            unique_id = plateform['infrastructure']['cloudsql']['instance-num']
        else:
            print("random string generate...")
            unique_id = randomString()

        print("unique-id:"+ unique_id)
        create_data(plateform, user1_password, user2_password, unique_id)
        plateform['infrastructure']['cloudsql']['instance-num']=unique_id

        for name in plateform['infrastructure']['namespaces']:
            create_namespace(name)


        print("Save SQL secrets in kubernetes")
        sa_key = get_service_account()
        save_secrets(user1_password, user2_password, sa_key)

        apply_kubernetes(plateform)

        with open('../plateform/manifests/dev-2.yaml', 'w') as yaml_file:
            yaml.dump(plateform, yaml_file, default_flow_style=False)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)

# To test:

# kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- mysql -h bdd.dev-3.internal.lp -uuser1-dev-3 -p