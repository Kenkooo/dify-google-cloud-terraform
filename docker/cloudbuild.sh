#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <project-id> <region> [dify-version] [dify-plugin-daemon-version]" >&2
  exit 1
fi

PROJECT_ID=$1
REGION=$2
DIFY_VERSION=${3:-"latest"}
DIFY_PLUGIN_DAEMON_VERSION=${4:-"${DIFY_VERSION}"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Submitting Cloud Build jobs with Dify version '${DIFY_VERSION}'" >&2
echo "(The same tag is used for the API, Sandbox, and Plugin Daemon images.)" >&2

# Nginx Build and Push
pushd "${SCRIPT_DIR}/nginx" >/dev/null
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION="$REGION",_PROJECT_ID="$PROJECT_ID"
popd >/dev/null

# API Build and Push
pushd "${SCRIPT_DIR}/api" >/dev/null
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION="$REGION",_PROJECT_ID="$PROJECT_ID",_DIFY_API_VERSION="$DIFY_VERSION"
popd >/dev/null

# Sandbox Build and Push
pushd "${SCRIPT_DIR}/sandbox" >/dev/null
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION="$REGION",_PROJECT_ID="$PROJECT_ID",_DIFY_SANDBOX_VERSION="$DIFY_VERSION"
popd >/dev/null

# Plugin Daemon Build and Push
pushd "${SCRIPT_DIR}/dify-plugin-daemon" >/dev/null
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION="$REGION",_PROJECT_ID="$PROJECT_ID",_DIFY_VERSION="$DIFY_VERSION"
popd >/dev/null
