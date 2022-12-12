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

# REF - https://juju.is/docs/olm/get-started-with-juju

msg "${GREEN}#1-Install MicroK8S ..${NOFORMAT}"
#sudo snap install microk8s --classic

msg "${GREEN}#2-Await installation..${NOFORMAT}"
microk8s status --wait-ready

# verify installation
msg "${GREEN}#3-Verify installation..${NOFORMAT}"
microk8s.kubectl get all --all-namespaces



newgrp microk8s
sudo usermod -a -G microk8s $UESR
sudo chown -f -R $UESR ~/.kube

microk8s enable hostpath-storage
microk8s enable dns
juju bootstrap microk8s micro

