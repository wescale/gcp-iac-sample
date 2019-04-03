#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

cd terraform
./destroy.sh $workspace
cd -