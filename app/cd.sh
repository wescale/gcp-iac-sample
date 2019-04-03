#!/bin/bash

version=$1

gsutil cp gs://charts-wescale-sandbox/app-chart/$version/app-chart-$version.tgz app-chart-$version.tgz 
# test if exist in helm list
# helm install app-chart-$version.tgz --name test-app
helm upgrade test-app app-chart-$version.tgz --set image.tag=$version
rm app-chart-$version.tgz
