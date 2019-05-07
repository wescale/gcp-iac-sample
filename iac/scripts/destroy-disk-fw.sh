#!/bin/bash

plateform=$1

first_fw_rule=$(gcloud compute firewall-rules list --filter=network=lp-net-$plateform --format=json | jq -r .[0].name)
gcloud -q compute firewall-rules delete $first_fw_rule

list_disk=$(gcloud compute disks list | grep lp-cluster-$plateform | cut -d ' ' -f1)
list_az=$(gcloud compute disks list | grep lp-cluster-$plateform | cut -d ' ' -f3)
list_disk_array=( $list_disk )
list_az_array=( $list_az )

for i in "${list_disk_array[@]}"
do
    echo "Disk delete named $i"
    gcloud -q compute disks delete $i --zone ${list_az_array[$it]}
    it=$((it+1))
    echo "Iterate $it"
done 
