#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/.homeserver"

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] [HELM_ARGS...]

Upgrade the homeserver Helm chart with optional custom parameters.

OPTIONS:
  -h, --help     Show this help message and exit

HELM_ARGS:
  Any additional arguments are passed directly to 'helm upgrade'.

EXAMPLES:
  # Standard upgrade
  $(basename "$0")

  # Upgrade with additional Helm values
  $(basename "$0") --set services.meilisearch.upgrade.enabled=true

EOF
}

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

# Parse command line arguments
helm_args=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      helm_args+=("$1")
      shift
      ;;
  esac
done

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

f_values=( -f values.yaml )
if [ -f "values.extend.yaml" ]; then
  f_values+=( -f values.extend.yaml )
fi

helm upgrade --install "$RELEASE_NAME" . \
  "${f_values[@]}" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  "${helm_args[@]}"

if [ $config_updated -eq 1 ]; then
  echo ""
  echo "---"
  echo ""
  echo "Deployment config saved to $CONFIG_FILE"
  echo "  Release Name: $RELEASE_NAME"
  echo "  Namespace: $NAMESPACE"
fi
