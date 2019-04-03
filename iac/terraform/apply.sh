#!/bin/bash

workspace=$1

if [ -z "$var" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... Terraform step"

cd layer-project
./apply.sh
cd -

cd layer-base
./apply.sh $workspace
cd -

cd layer-kubernetes
./apply.sh $workspace
cd -

cd layer-data
./apply.sh $workspace
cd -


