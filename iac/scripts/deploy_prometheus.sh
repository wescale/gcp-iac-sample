#!/bin/bash

name=$1
namespace=$2

cp scripts/prometheus-template.yaml prometheus-$name.yaml
sed -i.bak -e "s/NAME/$name/g" -e "s/NSPACE/$namespace/g" prometheus-$name.yaml

kubectl apply -f prometheus-$name.yaml

rm prometheus-$name.yaml
rm prometheus-$name.yaml.bak
