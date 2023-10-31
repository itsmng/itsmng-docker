#!/usr/bin/bash

podman run \
  --rm=true \
  -p 127.0.0.1:8080:8080 \
  --detach=false \
  --name=itsm \
  localhost/itsmng:1.5.1
