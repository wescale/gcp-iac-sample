#!/bin/bash

# TODO : gestion du workspace


cd layer-kubernetes
./destroy.sh
cd -

cd layer-data
./destroy.sh
cd -


cd layer-base
./destroy.sh
cd -

cd layer-project
./destroy.sh
cd -

