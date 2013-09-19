A bunch of scripts that come in handy to bootstrap Chef-server 11.08 on Ubuntu 12.04 (64 bits).

Installs ruby 1.9.3 (after having uninstalled the vanilla 1.8.7, if present), then Chef-server 11.08, and configures it.

Call it with
`/bin/bash -c "$(curl -L https://raw.github.com/wk8/chef-server-install/master/chef-server_install_wrapper.sh)"`
