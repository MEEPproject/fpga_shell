#!/bin/bash

GITLAB_URL="https://gitlab.bsc.es/"
GITLAB_TOKEN=$3
group="meep"
project=$1
job=$2

response=$(curl --location "$GITLAB_URL/api/v4/projects/${group}%2F${project}/jobs/$job/artifacts" \
 --output download.zip \
 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" )

