from python_terraform import Terraform, IsNotFlagged, IsFlagged
import subprocess
import base64
from requests import get


def create_project():
    tf = Terraform(working_dir='terraform/layer-project')
    code, _, _ = tf.apply(capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code != 0:
        raise Exception("error in Terraform layer-project")

def get_service_account():
    tf = Terraform(working_dir='terraform/layer-base')
    _, stdout, _ = tf.cmd("output app_a_key", capture_output=True, no_color=IsFlagged)
    return base64.b64decode(stdout)

def create_base(plateform):
    tf = Terraform(working_dir='terraform/layer-base')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.apply(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'range-ip': plateform['infrastructure']['range-ip'],
            'range-ip-pod': plateform['infrastructure']['range-ip-pod'],
            'range-ip-svc': plateform['infrastructure']['range-ip-svc'],
            'range-plateform': plateform['infrastructure']['range-plateform']
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)
    if code != 0:
        raise Exception("error in Terraform layer-base")

def delete_base(plateform):
    tf = Terraform(working_dir='terraform/layer-base')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.destroy(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'range-ip': plateform['infrastructure']['range-ip'],
            'range-ip-pod': plateform['infrastructure']['range-ip-pod'],
            'range-ip-svc': plateform['infrastructure']['range-ip-svc'],
            'range-plateform': plateform['infrastructure']['range-plateform']
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)
    if code != 0:
        raise Exception("error in Terraform layer-base")

def create_kubernetes(plateform):
    tf = Terraform(working_dir='terraform/layer-kubernetes')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    
    ip_1 = '10.0.0.1/32' 
    ip_2 = '10.0.0.1/32'
    ip_3 = '10.0.0.1/32'
    ip_4 = '10.0.0.1/32'
    ip_5 = get('https://api.ipify.org').text + "/32"
    if len(plateform['infrastructure']['gke']['ips_whitelist']) >= 1:
        ip_1 = plateform['infrastructure']['gke']['ips_whitelist'][0] + "/32"
    if len(plateform['infrastructure']['gke']['ips_whitelist']) >= 2:
        ip_2 = plateform['infrastructure']['gke']['ips_whitelist'][1] + "/32"
    if len(plateform['infrastructure']['gke']['ips_whitelist']) >= 3:
        ip_3 = plateform['infrastructure']['gke']['ips_whitelist'][2] + "/32"
    if len(plateform['infrastructure']['gke']['ips_whitelist']) >= 4:
        ip_4 = plateform['infrastructure']['gke']['ips_whitelist'][3] + "/32"

    code, _, _ = tf.apply(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'k8s-version': plateform['infrastructure']['gke']['version'],
            'preemptible': plateform['infrastructure']['gke']['preemptible'],
            'instance-type': plateform['infrastructure']['gke']['instance-type'],
            'white-ip-1': ip_1,
            'white-ip-2': ip_2,
            'white-ip-3': ip_3,
            'white-ip-4': ip_4,
            'white-ip-5': ip_5,
            'min_node': plateform['infrastructure']['gke']['min'],
            'max_node': plateform['infrastructure']['gke']['max'],
            'range_ip_master': plateform['infrastructure']['range-ip-master']
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    print("Post Apply script execution...")
    subprocess.call(["terraform/layer-kubernetes/apply_post.sh", plateform['name'], plateform['gcp-project']])

    if code != 0:
        raise Exception("error in Terraform layer-kubernetes")


def delete_kubernetes(plateform):
    tf = Terraform(working_dir='terraform/layer-kubernetes')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    
    ip_1 = '10.0.0.1/32' 
    ip_2 = '10.0.0.1/32'
    ip_3 = '10.0.0.1/32'
    ip_4 = '10.0.0.1/32'
    ip_5 = '10.0.0.1/32'

    code, _, _ = tf.destroy(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'k8s-version': plateform['infrastructure']['gke']['version'],
            'preemptible': plateform['infrastructure']['gke']['preemptible'],
            'instance-type': plateform['infrastructure']['gke']['instance-type'],
            'white-ip-1': ip_1,
            'white-ip-2': ip_2,
            'white-ip-3': ip_3,
            'white-ip-4': ip_4,
            'white-ip-5': ip_5,
            'min_node': plateform['infrastructure']['gke']['min'],
            'max_node': plateform['infrastructure']['gke']['max'],
            'range_ip_master': plateform['infrastructure']['range-ip-master']
        },
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    if code != 0:
        raise Exception("error in Terraform layer-kubernetes")


def create_data(plateform, user1_password, user2_password, unique_id):
    tf = Terraform(working_dir='terraform/layer-data')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.apply(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'database_version': plateform['infrastructure']['cloudsql']['version'],
            'database_instance_type': plateform['infrastructure']['cloudsql']['instance-type'],
            'database_disk_size': plateform['infrastructure']['cloudsql']['disk-size'],
            'user1_password': user1_password,
            'user2_password': user2_password,
            "unique_id": unique_id,
            'env': plateform['type']
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    if code != 0:
        raise Exception("error in Terraform layer-data")

def delete_data(plateform, user1_password, user2_password, unique_id):
    tf = Terraform(working_dir='terraform/layer-data')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.destroy(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'database_version': plateform['infrastructure']['cloudsql']['version'],
            'database_instance_type': plateform['infrastructure']['cloudsql']['instance-type'],
            'database_disk_size': plateform['infrastructure']['cloudsql']['disk-size'],
            'user1_password': user1_password,
            'user2_password': user2_password,
            "unique_id": unique_id,
            'env': plateform['type']
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    if code != 0:
        raise Exception("error in Terraform layer-data")

def create_bastion(plateform):
    tf = Terraform(working_dir='terraform/layer-bastion')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.apply(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'instance_type': plateform['infrastructure']['bastion']['instance-type'],
            'instance_image': plateform['infrastructure']['bastion']['image'],
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    if code != 0:
        raise Exception("error in Terraform layer-data")
    

def delete_bastion(plateform):
    tf = Terraform(working_dir='terraform/layer-bastion')
    code, _, _ = tf.cmd("workspace select " + plateform['name'], capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.destroy(
        var={
            'region': plateform['region'], 
            'remote_bucket': plateform['remote-bucket'],
            'prefix_bucket': plateform['prefix-bucket'],
            'gcp-project': plateform['gcp-project'],
            'instance_type': plateform['infrastructure']['bastion']['instance-type'],
            'instance_image': plateform['infrastructure']['bastion']['image'],
        }, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)

    if code != 0:
        raise Exception("error in Terraform layer-data")
    
def deploy_assets(name):
    subprocess.call(["scripts/deploy-statics.sh", name])

def delete_tfstate(name):
    subprocess.call(["scripts/destroy-gcs.sh", name])
