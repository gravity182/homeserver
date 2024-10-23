#!/usr/bin/env bash

helm install cert-manager jetstack/cert-manager \
  -f certmanager-values.yaml \
  --namespace cert-manager \
  --create-namespace \
  --version "v1.15.3"
helm install authentik authentik/authentik \
  -f authentik-values.yaml \
  --namespace authentik \
  --create-namespace \
  --version "2024.8.3"
helm install jellywatch . \
  -f secrets.yaml \
  --namespace homeserver \
  --create-namespace
