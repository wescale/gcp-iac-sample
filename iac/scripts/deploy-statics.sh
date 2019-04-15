#!/bin/bash

name=$1

gsutil cp ../app/static/LP-Box.svg gs://lp-static-bucket-$name/image.svg
gsutil iam ch allUsers:objectViewer gs://lp-static-bucket-$name
