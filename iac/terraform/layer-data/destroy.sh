#!/bin/bash


workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi
terraform workspace select $workspace

terraform destroy

