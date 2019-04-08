
from python_terraform import *
import subprocess

def create_project():
    tf = Terraform(working_dir='terraform/layer-project')
    code, stdout, stderr = tf.apply(capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    print(code)
    if code != 0:
        raise Exception("error in Terraform layer-project")

def create_base(plateform):
    tf = Terraform(working_dir='terraform/layer-base')
    code, stdout, stderr = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, stdout, stderr = tf.apply(
        var={'region': plateform['region'], 'gcp-project': plateform['gcp-project'] }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged)
    print(code)
    if code != 0:
        raise Exception("error in Terraform layer-base")

def create_kubernetes(plateform):
    tf = Terraform(working_dir='terraform/layer-kubernetes')
    code, stdout, stderr = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    
    approve = {"auto-approve": True}
    code, stdout, stderr = tf.apply(
        var={
            'region': plateform['region'], 
            'gcp-project': plateform['gcp-project'],
            'k8s-version': plateform['infrastructure']['gke']['version'],
            'preemptible': plateform['infrastructure']['gke']['preemptible'],
            'instance-type': plateform['infrastructure']['gke']['instance-type'],
            'myip': plateform['infrastructure']['gke']['ips_whitelist'][0]
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        **approve)

    print("Post Apply script execution...")
    subprocess.call(["terraform/layer-kubernetes/apply_post.sh", plateform['name'], plateform['gcp-project']])

    print(code)
    if code != 0:
        raise Exception("error in Terraform layer-kubernetes")


def create_data(plateform, user1_password, user2_password, unique_id):
    tf = Terraform(working_dir='terraform/layer-data')
    code, stdout, stderr = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, stdout, stderr = tf.apply(
        var={
            'region': plateform['region'], 
            'gcp-project': plateform['gcp-project'],
            'database_version': plateform['infrastructure']['cloudsql']['version'],
            'user1_password': user1_password,
            'user2_password': user2_password,
            "unique_id": unique_id
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged)

    print(code)
    if code != 0:
        raise Exception("error in Terraform layer-data")


def connect_gke(plateform):
    print("Connect to GKE...")
    subprocess.call(["scripts/connect-gke.sh", plateform['name'], plateform['region'] ,plateform['gcp-project']])
