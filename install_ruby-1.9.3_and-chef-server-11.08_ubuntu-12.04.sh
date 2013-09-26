#!/bin/bash
 
[[ `whoami` == 'root' ]] || eval 'echo "You must be root to run that script" && exit 1'

confirm () {
    read -r -p "$1 [Y/n] " response
    case $response in
        [yY][eE][sS]|[yY]) return 0;;
        [nN][oO]|[nN]) return 1 ;;
        *)
            echo "Please type Y or n"
            confirm $1
            return $?;;
    esac
}

set -e

# check that the hosntame is a FQDN (required according to http://docs.opscode.com/install_server.html)
# returns true iff the first argument looks like a FQDN
check_fqdn() {
    [ -z $(echo $1 | perl -wlne 'print $1 if /^([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])*)(\.[a-zA-Z0-9]{1}([a-zA-Z0-9\-]*[a-zA-Z0-9])*)*(\.[a-zA-Z]{1}([a-zA-Z0-9\-]*[a-zA-Z0-9])*)\.?$/') ] && return 1 || return 0
}
# set the hostname to whatever is the 1st argument
set_hostname() {
    echo "Setting hostname to $1"
    echo $1 > /etc/hostname
    service hostname restart &> /dev/null
    # Check that that hostname resolves to something; otherwise add it to /etc/hosts
    # (see https://tickets.opscode.com/browse/CHEF-3837)
    host $(hostname) > /dev/null && return 0
    LINE="127.0.0.1 $(hostname)"
    echo "Hostname $1 not resolving, appending to /etc/hosts : $LINE"
    echo "" >> /etc/hosts
    echo $LINE >> /etc/hosts
}
if ! check_fqdn $(hostname)
then
    echo "The hostname $(hostname) is not a FQDN! (which is required by Chef-server - see http://docs.opscode.com/install_server.html)"
    eval 'HOSTNAME=$(hostname --fqdn 2>&1) && check_fqdn $HOSTNAME' || HOSTNAME=''
    while [ -z $HOSTNAME ] || ! confirm "Use $HOSTNAME as hostname?"
    do
        read -r -p "Please enter a valid FQDN: " HOSTNAME
        check_fqdn $HOSTNAME || eval "echo '$HOSTNAME is not a valid FQDN' && HOSTNAME=''"
    done
    set_hostname $HOSTNAME
fi
 
# down to work! install ruby
curl -L https://raw.github.com/wk8/chef-server-install/master/install_ruby-1.9.3_ubuntu-12.04.sh | bash
 
# then install chef-server
PKG_NAME=chef-server_11.0.8-1.ubuntu.12.04_amd64.deb
cd /tmp && rm -f $PKG_NAME && wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/${PKG_NAME} \
    && dpkg -i $PKG_NAME

# configure chef
chef-server-ctl reconfigure

# check everything went OK
chef-server-ctl test

# install chef-client
curl -L http://www.opscode.com/chef/install.sh | bash

# install git
apt-get update
apt-get --force-yes --yes install git
