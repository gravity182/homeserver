#!/usr/bin/env bash

helm upgrade --install jellywatch . \
  -f values.yaml \
  --namespace homeserver
