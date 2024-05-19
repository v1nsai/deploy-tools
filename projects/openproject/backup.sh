#!/bin/bash

set -e

if 

docker exec -it openproject-db-1 pg_dump -U postgres -d openproject -x -O > /var/lib/openproject/openproject-backup.sql

timestamp=$(date +%Y-%m-%d-%H:%M)
BACKUPUSER=openproject-backup
BACKUPSERVER= # IP address of existing borgbackup server with SSH access
BACKUPREPO= # Path to borgbackup repository on the server, ie /var/backups/openproject

borg init $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO
borg create $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO::openproject-$timestamp /var/lib/openproject/openproject-backup.sql
borg create $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO::openproject-$timestamp-assets /var/lib/openproject/opdata
borg prune -v --list $BACKUPUSER@$BACKUPSERVER:$BACKUPREPO --keep-daily=7 --keep-weekly=4 --keep-monthly=6
