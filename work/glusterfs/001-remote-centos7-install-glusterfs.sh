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

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# declear array
declare -a array=()

# read file to array
msg "${GREEN}read file to array${NOFORMAT} .. "
while IFS= read -r line; do
    echo "Text read from file: $line"
    array=("${array[@]}" "$line")
done < farm-ips

# print array
msg "${GREEN}print array${NOFORMAT} .. "
for i in "${array[@]}"
do
   echo "$i"
done

# check package is installed
msg "${GREEN}check package is installed${NOFORMAT} .. "
for i in "${array[@]}"
do
   ssh centos@$i sudo yum list installed | grep glusterfs

   if [ $? -eq 0 ]; then
      msg "${RED}$i-${NOFORMAT}${GREEN}Package is installed${NOFORMAT} .. "

   else
      msg "${RED}$i-${NOFORMAT}${GREEN}Package is not installed${NOFORMAT} .. "
      for i in "${array[@]}"
      do
        ssh centos@$i sudo yum install centos-release-gluster -y
        ssh centos@$i sudo yum install glusterfs-server -y
        ssh centos@$i sudo systemctl enable glusterd
        ssh centos@$i sudo systemctl start glusterd
      done
   fi
done

# check firewalld port is open
msg "${GREEN}check firewalld port is open${NOFORMAT} .. "
for i in "${array[@]}"
do
   ssh centos@$i sudo firewall-cmd --list-ports | grep 24007

   if [ $? -eq 0 ]; then
      msg "${RED}$i ${NOFORMAT}${GREEN}Port is open${NOFORMAT} .. "
   else
      msg "${RED}$i ${NOFORMAT}${GREEN}Port not open${NOFORMAT} .. "
      for i in "${array[@]}"
      do
        ssh centos@$i sudo firewall-cmd --add-service=glusterfs --permanent
        ssh centos@$i sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
        ssh centos@$i sudo firewall-cmd --zone=public --add-port=24009/tcp --permanent
        ssh centos@$i sudo firewall-cmd --zone=public --add-service=nfs --add-service=samba --add-service=samba-client --permanent
        ssh centos@$i sudo firewall-cmd --zone=public --add-port=111/tcp --add-port=139/tcp --add-port=445/tcp --add-port=965/tcp --add-port=2049/tcp --add-port=38465-38469/tcp --add-port=631/tcp --add-port=111/udp --add-port=963/udp --add-port=49152-49251/tcp --permanent
        ssh centos@$i sudo firewall-cmd --reload
      done
   fi
done

# glusterd restart
msg "${GREEN}glusterd restart${NOFORMAT} .. "
for i in "${arr[@]}"
do
   echo "$i"

   ssh centos@$i sudo systemctl stop glusterd
   ssh centos@$i sudo systemctl start glusterd
done

# check peer status
msg "${GREEN}check peer status${NOFORMAT} .. "
for i in "${array[@]}"
do
   ssh centos@$i sudo gluster peer status

   if [ $? -eq 0 ]; then
      msg "${RED}$i-${NOFORMAT}${GREEN}Peer status is ok${NOFORMAT} .. "
   else
      msg "${RED}$i-${NOFORMAT}${GREEN}Peer status is not ok${NOFORMAT} .. "
      for i in "${array[@]}"
      do
        ssh centos@$i sudo gluster peer probe
      done
    fi
done

msg "${GREEN}gluster peer status${NOFORMAT} .. "

   ssh centos@${array[0]} sudo gluster peer status

msg "${RED}---------------------------------------- END ----------------------------------------${NOFORMAT} .. "