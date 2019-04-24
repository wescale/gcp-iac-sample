#!/usr/bin/env python

import yaml
from functions_iac import delete_kubernetes, delete_data, delete_base, delete_tfstate

name_file = raw_input("Nom du fichier: ")

with open("../plateform/manifests/"+name_file+".yaml", 'r') as stream:
    try:
        plateform=yaml.load(stream)
        print(plateform)

        print("Delete plateform with name: " + plateform['name'])

        if "gke" in plateform['infrastructure']:
            print("Layer-kubernetes...")
            delete_kubernetes(plateform)

        if 'cloudsql' in plateform['infrastructure']:
            print("Layer-data...")
            unique_id = 'test'
            if 'instance-num' in plateform['infrastructure']['cloudsql']:
                unique_id = plateform['infrastructure']['cloudsql']['instance-num']
                del plateform['infrastructure']['cloudsql']['instance-num']

            user1_password="test"
            user2_password="test"
            delete_data(plateform, user1_password, user2_password, unique_id)

            with open("../plateform/manifests/"+name_file+".yaml", 'w') as yaml_file:
                yaml.dump(plateform, yaml_file, default_flow_style=False)

        print("Layer-base...")
        delete_base(plateform)

        print("Delete tfstate...")
        delete_tfstate(plateform['name'])
        
    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)
