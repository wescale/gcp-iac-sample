from kubernetes import client, config, utils
from kubernetes.client.rest import ApiException
import base64
from utils_iac import randomString
import subprocess

def connect_gke(plateform):
    print("Connect to GKE...")
    subprocess.call(["scripts/connect-gke.sh", plateform['name'], plateform['region'] ,plateform['gcp-project']])

def create_namespace(name):
    print("Create namespace:" + name)
    config.load_kube_config()
    # subprocess.call(["scripts/create-ns.sh", name])
    api_instance = client.CoreV1Api()
    body = client.V1Namespace(metadata=client.V1ObjectMeta(name=name)) # V1Namespace | 
    
    try: 
        api_instance.create_namespace(body)
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespace: %s\n" % e)
        if e.status == 409:
            print("namespace already exist")
        else:
            print("%s\n" % e)

def apply_kubernetes(plateform):
    subprocess.call(["kubernetes/apply.sh", plateform['name']])

def save_secrets(user1_password, user2_password, sa_key, name):
    # subprocess.call(["scripts/create-secrets.sh", user1_password, user2_password])

    config.load_kube_config()
    api_instance = client.CoreV1Api()
    print("Create secret for 'cloudsql-secrets-user1'")
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="cloudsql-secrets-user1"))
    body.data = {
        "user": base64.b64encode("user1-"+name), 
        "password": base64.b64encode(user1_password)
    }
    body.type = "Opaque" 
    try:
        api_instance.create_namespaced_secret(body=body, namespace='webservices')
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e)
        if e.status == 409:
            print("secret already exist")
        else:
            print("%s\n" % e)
    
    print("Create secret for 'cloudsql-secrets-user2'")
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="cloudsql-secrets-user2"))
    body.data = {
        "user": base64.b64encode("user2-"+name), 
        "password": base64.b64encode(user2_password)
    }
    body.type = "Opaque"
    try:
        api_instance.create_namespaced_secret(body=body, namespace='webservices')
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e)
        if e.status == 409:
            print("secret already exist")
        else:
            print("%s\n" % e)


    print("Create secret for 'service-account'")
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="service-account"))
    body.data = {"sa-key": base64.b64encode(sa_key)}
    body.type = "Opaque"
    try:
        api_instance.create_namespaced_secret(body=body, namespace='webservices')
    except ApiException as e:
        # print("Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e)
        if e.status == 409:
            print("secret already exist")
        else:
            print("%s\n" % e)

def get_secret():
    config.load_kube_config()
    api_instance = client.CoreV1Api()
    try:
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-user1', namespace='webservices')
        password_user1 = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        print("cloudsql-secrets-user1 already exist")
        password_user1 = randomString()

    try:
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-user2', namespace='webservices')
        password_user2 = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        print("cloudsql-secrets-user2 already exist")
        password_user2 = randomString()

    return password_user1, password_user2

def deploy_helm(name, version, namespace):
    subprocess.call(["scripts/deploy-app-helm.sh", name, version, namespace])

def wait_cluster_if_exist(plateform):
    subprocess.call(["scripts/wait-master.sh", "lp-cluster-" + plateform['name'], plateform['region']])

