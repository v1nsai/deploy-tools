#!/bin/bash

set -e

docker-compose -f projects/homelab/$1/docker-compose.yml up -d
docker logs -f $1