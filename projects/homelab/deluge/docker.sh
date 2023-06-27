#!/bin/bash

set -e

docker run -d \
  --name=deluge \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e DELUGE_LOGLEVEL=error `#optional` \
  -p 8112:8112 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v /mnt/blackbox/media:/media \
  --restart unless-stopped \
  linuxserver/deluge:latest
