#!/bin/bash
 
# Only (optional) argument : --uninstall-1.8 to uninstall the native 1.8.7 version
 
[[ `whoami` == 'root' ]] || eval 'echo "You must be root to run that script" && exit 1'
 
[ -n "$2" ] || eval '[ -n "$1" ] && [[ $1 != "--dont-uninstall-1.8" ]]' && echo "The only supported optional agument is --dont-uninstall-1.8" && exit 1
 
echo "Installing ruby 1.9.3..."
 
set -e
# install the ruby1.9.1 package
apt-get update -q --yes
apt-get install -q --yes ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev
 
# set the alternatives
update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
    --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz \
    --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
    --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
    --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1
update-alternatives --config ruby

# update rubygems
cd /tmp && rm -f rubygems-2.1.5.tgz
wget http://production.cf.rubygems.org/rubygems/rubygems-2.1.5.tgz
tar xvzf rubygems-2.1.5.tgz
cd rubygems-2.1.5
ruby setup.rb
update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.9.1 400
update-alternatives --config gem && cd
 
# check that we've been successful
ruby -v | grep -E "^ruby 1\.9\.3" &> /dev/null && echo "Ruby 1.9.3 successfully installed" || eval 'echo "Wrong ruby version after install!" && exit 1'
[[ `gem -v` == '2.1.5' ]] && echo "Gem 2.1.5 successfully installed" || eval 'echo "Wrong gem version after install!" && exit 1'

# if we were asked to not uninstall, we can stop here
[[ $1 == "--dont-uninstall-1.8" ]] && exit 0 || echo "Uninstalling vanilla ruby 1.8.7..." 
 
# uninstall all gems from the 1.8 installation, if any
if which gem1.8
then
    gem1.8 list | cut -d" " -f1 | xargs gem1.8 uninstall -aIx
else
    echo "gem1.8 not found, skipping uninstalling gems"
fi
 
# remove the ruby1.8 packages
apt-get remove -q --yes libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8
 
# check for any lingering package
DPKG_COMMAND="dpkg --get-selections *ruby1.8* | grep -v deinstall"
$DPKG_COMMAND &> /dev/null && eval 'echo "Looks like some ruby packages are still hanging around, please check manually by running
$DPKG_COMMAND" && exit 1'
 
echo "Successfully uninstalled ruby 1.8.7!"
