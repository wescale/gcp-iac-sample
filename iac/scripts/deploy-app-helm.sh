#!/bin/bash

name=$1
version=$2
namespace=$3

gsutil cp gs://charts-wescale-sandbox/$name/$version/$name-$version.tgz $name-$version.tgz 
# test if exist in helm list
$(helm status $name)
if [ $? -eq 0 ]
then 
    helm upgrade $name $name-$version.tgz --set image.tag=$version
else
    helm install $name-$version.tgz --name $name --namespace $namespace
fi

rm $name-$version.tgz
