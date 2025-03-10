#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$(pwd)/.homeserver"

ask_for_input() {
  local prompt="$1"

  read -r -p "$prompt: " user_input

  if [ -z "$user_input" ]; then
    echo "No value provided" >&2
    exit 1
  else
    echo "$user_input"
  fi
}

config_updated=0

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

set +u
if [ -z "$RELEASE_NAME" ]; then
  RELEASE_NAME=$(ask_for_input "Enter release name")
  config_updated=1
fi
set -u

set +u
if [ -z "$NAMESPACE" ]; then
  NAMESPACE=$(ask_for_input "Enter namespace")
  config_updated=1
fi
set -u

if [ $config_updated -eq 1 ]; then
  echo "RELEASE_NAME=\"$RELEASE_NAME\"" > "$CONFIG_FILE"
  echo "NAMESPACE=\"$NAMESPACE\"" >> "$CONFIG_FILE"
fi

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.crds.yaml
helm install "$RELEASE_NAME" . \
  -f values.yaml \
  --namespace "$NAMESPACE"

if [ $config_updated -eq 1 ]; then
  echo "---"
  echo "Deployment config saved to $CONFIG_FILE"
  echo "  Release Name: $RELEASE_NAME"
  echo "  Namespace: $NAMESPACE"
fi
