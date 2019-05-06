#!/bin/bash

workspace=$1
GCP_PROJECT=$2

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-kubernetes"


ig=$(gcloud compute instance-groups list --project slavayssiere-sandbox --project $GCP_PROJECT | grep np-default | cut -d ' ' -f1)
az=$(gcloud compute instance-groups list --project slavayssiere-sandbox --project $GCP_PROJECT | grep np-default | cut -d ' ' -f3)
ig_array=( $ig )
az_array=( $az )
it=0
for i in "${ig_array[@]}"
do
    echo "Port named for $i"
    gcloud compute instance-groups set-named-ports $i --named-ports=http:31080 --project $GCP_PROJECT --zone ${az_array[$it]}
    it=$((it+1))
    echo "Iterate $it"
done 
