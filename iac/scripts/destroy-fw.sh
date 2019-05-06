#!/bin/bash

plateform=$1

first_fw_rule=$(gcloud compute firewall-rules list --filter=network=lp-net-$plateform --format=json | jq -r .[0].name)
gcloud -q compute firewall-rules delete $first_fw_rule

