#!/bin/bash

# TODO : gestion du workspace

cd layer-project
./apply.sh
cd -

cd layer-base
./apply.sh
cd -

cd layer-kubernetes
./apply.sh
cd -

cd layer-data
./apply.sh
cd -


