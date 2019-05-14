#!/bin/bash

gcloud auth activate-service-account $GOOGLE_SA --key-file=$GOOGLE_SA_PATH
gcloud config set account $GOOGLE_SA

sed -i.bak "s/GOOGLE_CLIENT_ID/$GOOGLE_CLIENT_ID/g" /app/conf/conf.json
sed -i.bak "s/GOOGLE_SECRET/$GOOGLE_SECRET/g" /app/conf/conf.json

cd scripts
./init-layers.sh
cd -

python3 launcher.py
