#!/bin/bash


workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform..."

cd terraform
./apply.sh $workspace
cd -

cd kubernetes 
./apply.sh $workspace
cd -
