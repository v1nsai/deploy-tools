#!/bin/bash

set -e

docker run --rm -it \
    --name protonmail-bridge \
    --volume protonmail:/root \
    shenxn/protonmail-bridge init
docker run -d --name=protonmail-bridge \
    --volume protonmail:/root \
    --publish 25:25/tcp \
    --publish 143:143/tcp \
    --restart=unless-stopped \
    --network nextcloud-aio \
    shenxn/protonmail-bridge

# docker compose
# docker-compose up protonmail-bridge-init
# docker-compose up -d protonmail-bridge