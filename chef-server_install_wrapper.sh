#!/bin/bash
 
TMP_FILE=$(mktemp)
URL=https://raw.github.com/gist/6437059
 
wget $URL -O $TMP_FILE
 
bash $TMP_FILE

rm $TMP_FILE
