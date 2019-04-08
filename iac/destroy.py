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

        print("Delete plateform with name: " + plateform['name'])

        print("Layer-kubernetes...")
        delete_kubernetes(plateform)

        print("Layer-data...")
        unique_id = plateform['infrastructure']['cloudsql']['instance-num']
        del plateform['infrastructure']['cloudsql']['instance-num']


        user1_password="test"
        user2_password="test"
        delete_data(plateform, user1_password, user2_password, unique_id)

        print("Layer-base...")
        delete_base(plateform)

        # print("Layer-project...")
        # create_project()
        
        with open("../plateform/manifests/"+name+".yaml", 'w') as yaml_file:
            yaml.dump(plateform, yaml_file, default_flow_style=False)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)
