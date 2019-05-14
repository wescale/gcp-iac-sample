#!/bin/bash

backend_bucket="tf-slavayssiere-wescale"
backend_prefix="gcp-sample-iac"

cd terraform/layer-project
rm -Rf .terraform
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix/layer-project"
cd -

cd terraform/layer-base
rm -Rf .terraform
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix/layer-base"
cd -

cd terraform/layer-bastion
rm -Rf .terraform
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix/layer-bastion"
cd -

cd terraform/layer-kubernetes
rm -Rf .terraform
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix/layer-kubernetes"
cd -

cd terraform/layer-data
rm -Rf .terraform
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix/layer-data"
cd -


