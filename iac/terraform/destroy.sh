#!/bin/bash

# TODO : gestion du workspace


workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

cd layer-kubernetes
./destroy.sh $workspace
cd -

cd layer-data
./destroy.sh $workspace
cd -


cd layer-base
./destroy.sh $workspace
cd -

cd layer-project
./destroy.sh
cd -

