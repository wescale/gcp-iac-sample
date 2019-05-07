#!/bin/bash

plateform=$1

first_fw_rule=$(gcloud compute firewall-rules list --filter=network=lp-net-$plateform --format=json | jq -r .[0].name)
gcloud -q compute firewall-rules delete $first_fw_rule

list_disk=$(gcloud compute disks list | grep lp-cluster-$plateform | cut -d ' ' -f1)
gcloud -q compute disks delete $list_disk
