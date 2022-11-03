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

## declare an array variable
declare -a arr=(
"192.168.10.18"
"192.168.10.19"
"192.168.10.8"
"192.168.10.20"
"192.168.10.9"
"192.168.10.7"
"192.168.10.14"
)

## now loop through the above array
for i in "${arr[@]}"
do
   echo "$i"
   scp centos7-install-glusterfs.sh centos@$i:~
   scp gluster-special-set.sh centos@$i:~
done

