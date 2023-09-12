#!/bin/bash

set -e

docker-compose up -d
docker exec -it superset superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin

docker exec -it superset superset db upgrade
docker exec -it superset superset load_examples
docker exec -it superset superset init
docker restart superset