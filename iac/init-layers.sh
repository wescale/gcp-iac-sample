#!/bin/bash

gcloud config set core/account slavayssiere-sandbox
backend_bucket="tf-slavayssiere-wescale"
backend_prefix="gcp-sample-iac/layer-base"

cd terraform/layer-project
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix"
cd -

cd terraform/layer-base
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix"
cd -

cd terraform/layer-kubernetes
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix"
cd -

cd terraform/layer-data
terraform init \
    -backend-config="bucket=$backend_bucket" \
    -backend-config="prefix=$backend_prefix"
cd -


