#!/usr/bin/env python

import yaml
from python_terraform import *
from functions_iac import *
import random
import string

def randomString(stringLength=10):
    """Generate a random string of fixed length """
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))


with open("../plateform/manifests/dev-2.yaml", 'r') as stream:
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

        print("Layer-data...")
        user1_password = randomString()
        user2_password = randomString()
        create_data(plateform, user1_password, user2_password)

        connect_gke(plateform)

        for name in plateform['infrastructure']['namespaces']:
            create_namespace(name)

        apply_kubernetes(plateform)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)