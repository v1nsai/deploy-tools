#!/bin/bash

set -e

if 

docker exec -it openproject-db-1 pg_dump -U postgres -d openproject -x -O > /var/lib/openproject/openproject-backup.sql

timestamp=$(date +%Y-%m-%d-%H:%M)

borg init $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO
borg create $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO::openproject-$timestamp /var/lib/openproject/openproject-backup.sql
borg create $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO::openproject-$timestamp-assets /var/lib/openproject/opdata
