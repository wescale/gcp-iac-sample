from kubernetes import client, config, utils
from kubernetes.client.rest import ApiException
import base64
from utils_iac import randomString
import subprocess

def create_namespace(name):
    print("Create namespace:" + name)
    config.load_kube_config()
    # subprocess.call(["scripts/create-ns.sh", name])
    api_instance = client.CoreV1Api()
    body = client.V1Namespace(metadata=client.V1ObjectMeta(name=name)) # V1Namespace | 
    
    try: 
        api_response = api_instance.create_namespace(body)
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespace: %s\n" % e)
        if e.status == 409:
            print("namespace already exist")
        else:
            print("%s\n" % e)

def apply_kubernetes(plateform):
    subprocess.call(["kubernetes/apply.sh", plateform['name']])

def save_secrets(user1_password, user2_password):
    subprocess.call(["scripts/create-secrets.sh", user1_password, user2_password])

def get_secret():
    config.load_kube_config()
    api_instance = client.CoreV1Api()
    try:
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-user1', namespace='webservices')
        password_user1 = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        password_user1 = randomString()

    try:
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-user2', namespace='webservices')
        password_user2 = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        password_user2 = randomString()

    return password_user1, password_user2

    