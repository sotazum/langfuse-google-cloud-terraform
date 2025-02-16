#!/bin/bash

PROJECT_ID=$1
REGION=$2
REPOSITORY_ID=$3
TAG=$4

cd docker/web
gcloud builds submit --config=cloudbuild.yml --substitutions=_REGION=$REGION,_PROJECT_ID=$PROJECT_ID,_REPOSITORY_ID=$REPOSITORY_ID,_TAG=$TAG
cd ../..