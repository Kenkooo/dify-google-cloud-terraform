#!/bin/bash

PROJECT_ID=$1
REGION=$2
DIFY_VERSION=${3:-"latest"}

# Nginx Build and Push
pushd docker/nginx
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION=$REGION,_PROJECT_ID=$PROJECT_ID
popd

# API Build and Push
pushd docker/api
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION=$REGION,_PROJECT_ID=$PROJECT_ID,_DIFY_API_VERSION=$DIFY_VERSION
popd

# Sandbox Build and Push
pushd docker/sandbox
gcloud builds submit --config=cloudbuild.yaml --substitutions=_REGION=$REGION,_PROJECT_ID=$PROJECT_ID,_DIFY_SANDBOX_VERSION=$DIFY_VERSION
popd
