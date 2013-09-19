#!/bin/bash
 
TMP_FILE=$(mktemp)
URL=https://raw.github.com/wk8/chef-server-install/master/install_ruby-1.9.3_and-chef-server-11.08_ubuntu-12.04.sh
 
wget $URL -O $TMP_FILE
 
bash $TMP_FILE

rm $TMP_FILE
