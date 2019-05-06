#!/bin/bash

name=$1

gsutil cp ../app/static/LP-Box.svg gs://lp-public-static-bucket-$name/static/image.svg
gsutil cp ../app/static/LP-Box.svg gs://lp-private-static-bucket-$name/static/image.svg
gsutil iam ch allUsers:objectViewer gs://lp-public-static-bucket-$name
gsutil iam ch allUsers:objectViewer gs://lp-private-static-bucket-$name
