#!/bin/bash

MYIP=$(curl ifconfig.me)

terraform destroy \
    --var "myip=$MYIP"

