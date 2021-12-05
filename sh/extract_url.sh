#!/bin/bash

EMPTY=""
EA_REPO="EMULATED_ACCELERATOR_REPO"
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE="ea_url.txt"
YAML_FILE=$1

if [ "$YAML_FILE" = "" ]; then
	YAML_FILE=".gitlab-ci.yml"
fi

# Seach the YAML File token-based URL and convert it to a normal URL
EA_REPO_TMP=$(grep $DEF_FILE -e "$EA_REPO") 
# Take a normal URL and insert the token-based string
EA_REPO_YAML=$(grep $DEF_FILE -e "$EA_REPO" | sed "s/https:\/\//https:\/\/gitlab-ci-token:\$RTL_REPO_TOKEN@/")


echo "$EA_REPO_TMP"
echo "$EA_REPO_YAML"

#Substitue the entire line where a match to $EA_REPO has been found thanks to .* after the matching 
#string. If .* is not present, only the matching string gets substitued.
sed -i "0,/$EA_REPO/{s|$EA_REPO.*|$EA_REPO_YAML|}" $YAML_FILE

#Do the same process (almost) for the SHA line
#1 obtain the right line
EA_SHA_TMP=$(grep $DEF_FILE -e "$EA_SHA")

echo "$EA_SHA_TMP"

#switch the lines

sed -i "0,/$EA_SHA/{s|$EA_SHA.*|$EA_SHA_TMP|}" $YAML_FILE



