#!/bin/bash

workspace=$1

cd ../iac/terraform/layer-base
terraform workspace new $workspace
cd -

cd ../iac/terraform/layer-kubernetes
terraform workspace new $workspace
cd -

cd ../iac/terraform/layer-data
terraform workspace new $workspace
cd -

