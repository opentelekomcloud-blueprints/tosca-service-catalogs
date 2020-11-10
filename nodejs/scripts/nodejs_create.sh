#!/bin/bash

#source $utils_scripts/utils.sh

# TODO
# Print a log message with the timestamp and level
# params:
#   1- Logging level (debug, info, warning, error)
#   2- Logging message
# Note: do not use ctx for now as it wont work: https://fastconnect.org/jira/browse/SUPALIEN-543
log () {
    local level=$1
    shift
    local time=$(date '+%F %R ')
    local file=$(basename $0)
    local message="$*"
    case "${level,,}" in
      begin) echo "$time INFO: $file : >>> Begin <<< $message" ;;
      end) echo "$time INFO: $file : >>> End   <<< $message" ;;
      *) echo "$time ${level^^}: $file : $message" ;;
    esac
}

log begin
log info "BEGIN install node.js"

log info "apt-get update"
sudo apt-get update

log info "installing nodejs version ${COMPONENT_VERSION}"
curl -sL https://deb.nodesource.com/setup_${COMPONENT_VERSION} | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install forever -g

log info "installing gcc, g++, make"
sudo apt install -y gcc g++ make

sudo chown -R $USER:$(id -gn $USER) ~/.config
sudo chown -R $USER:$(id -gn $USER) ~/.npm

log info "ln -s /usr/bin/nodejs /usr/bin/node"
sudo ln -s /usr/bin/nodejs /usr/bin/node

log info "END install node.js"
