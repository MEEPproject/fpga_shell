#!/bin/bash

EMPTY=""
EA_REPO="EMULATED_ACCELERATOR_REPO"
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE="ea_url.txt"

# Seach the YAML File token-based URL and convert it to a normal URL
#EA_REPO_YAML=$(cat ea_url.txt | sed "s/gitlab-ci-token:\$RTL_REPO_TOKEN@/$EMPTY/")
EA_REPO_TMP=$(grep $DEF_FILE -e "$EA_REPO") 
# Take a normal URL and insert the token-based string
EA_REPO_YAML=$(grep $DEF_FILE -e "$EA_REPO" | sed "s/https:\/\//https:\/\/gitlab-ci-token:\$RTL_REPO_TOKEN@/")


echo "$EA_REPO_TMP"
echo "$EA_REPO_YAML"

sed -i "s|$EA_REPO_TMP|$EA_REPO_YAML|" $DEF_FILE


