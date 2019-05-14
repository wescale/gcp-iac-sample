from kubernetes import client, config, utils
from kubernetes.client.rest import ApiException
import base64
from utils_iac import randomString
import subprocess
import os
from time import sleep

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

def apply_kubernetes(name):
    subprocess.call(["kubernetes/apply.sh", name])

def post_kubernetes(name):
    subprocess.call(["kubernetes/post.sh", name])

def install_consul(name, version_chart):
    subprocess.call(["kubernetes/consul/install.sh", name, version_chart])

def install_prometheus_operator(name, version_chart):
    subprocess.call(["kubernetes/prometheus-operator/install.sh", name, version_chart])

def install_traefik(name, version_chart, version_app):
    subprocess.call(["kubernetes/traefik/install.sh", name, version_chart, version_app])

def save_secrets(admin_password, app_password, sa_key, name):
    config.load_kube_config()
    api_instance = client.CoreV1Api()
    print("Create secret for 'cloudsql-secrets-admin'")
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="cloudsql-secrets-admin"))
    body.data = {
        "user": base64.b64encode("admin-"+name), 
        "password": base64.b64encode(admin_password)
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
    
    print("Create secret for 'cloudsql-secrets-app'")
    body = client.V1Secret(metadata=client.V1ObjectMeta(name="cloudsql-secrets-app"))
    body.data = {
        "user": base64.b64encode("app-"+name), 
        "password": base64.b64encode(app_password)
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
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-admin', namespace='webservices')
        password_admin = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        print("cloudsql-secrets-admin not exist")
        password_admin = randomString()

    try:
        api_response = api_instance.read_namespaced_secret(name='cloudsql-secrets-app', namespace='webservices')
        password_app = base64.b64decode(api_response.data['password'])
    except ApiException as e:
        # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
        print("cloudsql-secrets-app not exist")
        password_app = randomString()

    return password_admin, password_app

def deploy_helm(name, version, namespace):
    subprocess.call(["scripts/deploy-app-helm.sh", name, version, namespace])

def wait_cluster_if_exist(plateform):
    subprocess.call(["scripts/wait-master.sh", "lp-cluster-" + plateform['name'], plateform['region']])

def deploy_yaml(name, app, password_admin):
    config.load_kube_config()
    api_instance = client.CoreV1Api()

    if 'cloudsql' in app:
        password = ''
        ################### gestion du secret dans k8s #####################
        try:
            api_response = api_instance.read_namespaced_secret(name=app['cloudsql']['user-secret'], namespace=app['namespace'])
            password = base64.b64decode(api_response.data['password'])
        except ApiException as e:
            # print("Exception when calling CoreV1Api->read_secret: %s\n" % e)
            print(app['cloudsql']['user-secret']+" not exist")
            password = randomString()

            body = client.V1Secret(metadata=client.V1ObjectMeta(name=app['cloudsql']['user-secret']))
            body.data = {
                "user": base64.b64encode(app['name']+"-"+name), 
                "password": base64.b64encode(password),
                "database": base64.b64encode(app['cloudsql']['database'])
            }
            body.type = "Opaque"
            try:
                api_instance.create_namespaced_secret(body=body, namespace=app['namespace'])
            except ApiException as e:
                # print("Exception when calling CoreV1Api->create_namespaced_secret: %s\n" % e)
                if e.status == 409:
                    print("secret "+app['cloudsql']['user-secret']+" already exist")
                else:
                    print("%s\n" % e)

        
        ################### creation du user et database #####################
        api_instance = client.BatchV1Api()

        try:
            api_response = api_instance.delete_namespaced_job(name="create-sql-job-"+app['name'], namespace=app['namespace'])
        except ApiException as e:
            print("Exception when calling BatchV1Api->delete_namespaced_job: %s\n" % e)
        except Exception as e:
            print("Exception in create %s\n" % e)
        
        body = kube_create_job_object("create-sql-job-"+app['name'], 
            "eu.gcr.io/slavayssiere-sandbox/sql-job:0.0.4", 
            namespace=app['namespace'],
            env_vars={
                "MYSQL_HOST":"bdd.dev-2.internal.lp",
                "MYSQL_PORT":"3306",
                "MYSQL_USER":"admin-"+name,
                "MYSQL_PASSWORD":password_admin,
                "CREATE_DATABASE":app['cloudsql']['database'],
                "CREATE_USER":app['name']+"-"+name,
                "CREATE_PASSWORD":password
            })
        try: 
            api_response = api_instance.create_namespaced_job(app['namespace'], body, pretty=True)
        except ApiException as e:
            print("Exception when calling BatchV1Api->create_namespaced_job: %s\n" % e)
        except Exception as e:
            print("Exception in create %s\n" % e)

    k8s_client = client.ApiClient()
    for path in app['paths']:
        print("Apply: " + path)
        utils.create_from_yaml(k8s_client, os.getcwd() + "/" + path)
    print("Deployment "+app['name']+" created")
        
        
def kube_create_job_object(name, container_image, namespace="default", container_name="jobcontainer", env_vars={}):
    # Body is the object Body
    body = client.V1Job(api_version="batch/v1", kind="Job")
    # Body needs Metadata
    # Attention: Each JOB must have a different name!
    body.metadata = client.V1ObjectMeta(namespace=namespace, name=name)
    # And a Status
    body.status = client.V1JobStatus()
     # Now we start with the Template...
    template = client.V1PodTemplate()
    template.template = client.V1PodTemplateSpec()
    # Passing Arguments in Env:
    env_list = []
    for env_name, env_value in env_vars.items():
        env_list.append( client.V1EnvVar(name=env_name, value=env_value) )
    container = client.V1Container(name=container_name, image=container_image, env=env_list)
    template.template.spec = client.V1PodSpec(containers=[container], restart_policy='Never')
    # And finaly we can create our V1JobSpec!
    body.spec = client.V1JobSpec(ttl_seconds_after_finished=30, template=template.template)
    return body

