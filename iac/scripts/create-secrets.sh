#!/bin/bash

user1_password=$1
user2_password=$2

kubectl -n webservices create secret generic cloudsql-secrets-user1 \
    --from-literal=user=user1 --from-literal=password=$user1_password

kubectl -n webservices create secret generic cloudsql-secrets-user2 \
    --from-literal=user=user2 --from-literal=password=$user2_password

