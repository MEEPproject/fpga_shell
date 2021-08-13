#!/bin/bash

ROOT_DIR=$(pwd)
EA_SHA="EMULATED_ACCELERATOR_SHA"
DEF_FILE=$1
ACC_DIR=$ROOT_DIR/accelerator

cd $ACC_DIR
EA_SHA_BRANCH=$(git branch --show-current)
EA_SHA_TMP=$(git rev-parse $EA_SHA_BRANCH)
cd $ROOT_DIR

echo "$EA_SHA: $EA_SHA_TMP"
NEW_SHA="$EA_SHA: $EA_SHA_TMP"

#switch the lines

sed -i "0,/$EA_SHA/{s|$EA_SHA.*|$NEW_SHA|}" $DEF_FILE



