#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

    msg "${RED}------------------------------ CLEANUP ------------------------------${NOFORMAT} .. "
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

# declear array
declare -a array=()
FILE_NAME="farm-ips"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# read file to array
msg "${GREEN}read file to array${NOFORMAT} .. "
while IFS= read -r line; do
    echo "Text read from file: $line"
    array=("${array[@]}" "$line")
done < ${FILE_NAME}

# print array
#msg "${GREEN}print array${NOFORMAT} .. "
#for i in "${array[@]}"
#do
#   echo "$i"
#done

# install the pre-requisites packages for CentOS 7
msg "#1-${GREEN}install the pre-requisites packages for CentOS 7${NOFORMAT} .. "
for i in "${array[@]}"
do
   # install ip address
   msg "---${BLUE}install node ip:$i${NOFORMAT} .. "
   ssh centos@$i sudo yum install -q -y epel-release
   ssh centos@$i sudo yum install -q -y gcc make rpm-build libtool hwloc-devel \
                                     libX11-devel libXt-devel libedit-devel libical-devel \
                                     ncurses-devel perl postgresql-devel postgresql-contrib \
                                     python3-devel tcl-devel tk-devel swig expat-devel \
                                     openssl-devel libXext libXft autoconf automake gcc-c++ \
                                     vim wget curl git

done

# In addtion, you need to install the following packages 
msg "#2-${GREEN}In addtion, you need to install the following packages${NOFORMAT} .. "
for i in "${array[@]}"
do
   # install ip address
   msg "---${BLUE}install node ip:$i${NOFORMAT} .. "
   ssh centos@$i sudo yum install -q -y expat libedit postgresql-server postgresql-contrib python3 \
      sendmail sudo tcl tk libical
done
