#!/bin/bash

cd terraform
./apply.sh
cd -

cd kubernetes 
./apply.sh
cd -
