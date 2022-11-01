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

# enabled maas tls
msg "${GREEN}Enable MAAS TLS${NOFORMAT} .. "
sudo maas config-tls enable 

sudo maas apikey --username falinux

# using the CLI with a TLS-enabled MAAS
msg "${GREEN}Using the CLI with a TLS-enabled MAAS${NOFORMAT} .. "
sudo maas login falinux https://localhost:5240/MAAS/api/2.0/

