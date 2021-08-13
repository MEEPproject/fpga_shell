#!/bin/bash

EMPTY=""
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE=$1

#Do the same process (almost) for the SHA line
#1 obtain the right line
EA_SHA_BRANCH=$(git branch --show-current)
EA_SHA_TMP=$(git rev-parse $EA_SHA_BRANCH)

echo "$EA_SHA: $EA_SHA_TMP"
NEW_SHA="$EA_SHA: $EA_SHA_TMP"

#switch the lines

sed -i "0,/$EA_SHA/{s|$EA_SHA.*|$NEW_SHA|}" $DEF_FILE



