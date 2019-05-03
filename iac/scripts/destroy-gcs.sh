#!/bin/bash

name=$1

gsutil rm gs://tf-slavayssiere-wescale/gcp-sample-iac/layer-base/$name.tfstate
gsutil rm gs://tf-slavayssiere-wescale/gcp-sample-iac/layer-bastion/$name.tfstate
gsutil rm gs://tf-slavayssiere-wescale/gcp-sample-iac/layer-data/$name.tfstate
gsutil rm gs://tf-slavayssiere-wescale/gcp-sample-iac/layer-kubernetes/$name.tfstate

