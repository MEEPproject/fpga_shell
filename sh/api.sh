#!/bin/bash

GITLAB_URL="https://gitlab.bsc.es/"
GITLAB_TOKEN="vZbY2sBxUhDnCYG6gxRH"
group="meep"
project="FPGA_implementations%2FAlveoU280%2Frepo_generation_script"
branch="origin%2Fdevelop%2Fhbm"
job="219155"
THIS_REPO="FPGA_implementations%2FAlveoU280%2Frepo_generation_script"
LAST_BINARIES_JOB="219155"


curl -L --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/projects/${group}%2F${project}/jobs/$job/artifacts" --output watcher
#curl -L --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.bsc.es/api/v4/projects/${project}/jobs/$LAST_BINARIES_JOB/artifacts" --output binaries.zip

