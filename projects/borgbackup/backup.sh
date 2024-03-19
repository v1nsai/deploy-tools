#!/bin/bash

export BORG_REPO='ssh://openproject@216.87.32.102:22/home/openproject/repo'

docker exec -it openproject-db-1 pg_dump -U postgres -d openproject -x -O > openproject.sql
borg init --encryption repokey $BORG_REPO
