#!/bin/bash

plateform=$1
sudo apt-get install kubectl


REGION="europe-west1"
NAME_CLUSTER="lp-cluster-$plateform"

echo "gcloud config set compute/region $REGION" | sudo tee --append /home/slavayssiere/.bashrc  > /dev/null
echo "gcloud container clusters get-credentials $NAME_CLUSTER --region $REGION" | sudo tee --append /home/slavayssiere/.bashrc  > /dev/null
echo "alias ll='ls -lisa'" | sudo tee --append /home/slavayssiere/.bashrc  > /dev/null
echo "source <(kubectl completion bash)" >> ~/.bashrc
