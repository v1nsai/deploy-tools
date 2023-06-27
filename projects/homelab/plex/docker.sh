#!/bin/bash 

set -e

docker run -d \
  --name=plex \
  --net=host \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e VERSION=docker \
  -v /mnt/blackbox/media:/media \
  --restart unless-stopped \
  lscr.io/linuxserver/plex:latest