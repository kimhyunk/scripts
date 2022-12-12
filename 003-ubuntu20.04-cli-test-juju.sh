#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

setup_colors

VER="1.0.0"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# user input case statement
echo -e "--------------------------------------------------------------------------------"
echo -e "Select from the following options:"
echo -e "\t0) clean up juju"
echo -e "\t1) Set up the Dashboard"
echo -e "\t2) juju bootstrap"
echo -e "\t3) Set up the Dashboard"
echo -e "\t4) configure LXD"
echo -e "\t5) Create a controller"
read -p "Enter your choice [ 1 - 4 ]: " choice
echo "--------------------------------------------------------------------------------"

# REF - https://pwittrock.github.io/docs/getting-started-guides/ubuntu/installation/

case $choice in
  0)
    msg "${GREEN}#-$choice clean up juju${NOFORMAT}"
    sudo snap remove --purge juju
  ;;
  1) 
    msg "${GREEN}#-$choice Set up the Dashboard${NOFORMAT}"
    juju bootstrap localhost mylocalcontroller --debug
    juju status
  ;;
  2)
    msg "${GREEN}#-$choice juju bootstrap${NOFORMAT}"

#    PROXY_HTTP="http://cloud-images.ubuntu.com"

#    export http_proxy=$PROXY_HTTP


    juju bootstrap bootstrap \
    --model-default agent-metadata-url=$LOCAL_AGENTS \
    --model-default image-metadata-url=$LOCAL_IMAGES \
    localhost
  ;; 
  3)
    msg "${GREEN}#-$choice Set up the Dashboard${NOFORMAT}"
    juju status
    exit
  ;;
  4)
    msg "${GREEN}#-$choice configure LXD${NOFORMAT}"
    newgrp lxd
    sudo adduser $USER lxd
    lxd init --auto
    juju clouds
  ;;
  5)
    msg "${GREEN}#-$choice Create a controller${NOFORMAT}"
    juju bootstrap localhost overlord --debug
    juju status
  ;;
  *) 
  $choice 
  msg "${RED}Error...${NOFORMAT}";;
esac
