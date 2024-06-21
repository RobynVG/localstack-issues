#!/bin/sh
set -e

rm -rf terraform.tfstate

docker compose up -d --wait

tflocal init

tflocal apply --auto-approve