#!/bin/bash

cd layer-project
terraform init
cd -

cd layer-base
terraform init
cd -

cd layer-kubernetes
terraform init
cd -

cd layer-data
terraform init
cd -


