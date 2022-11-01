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
declare -a array=()
declare -a array_brick=()
FILE_NAME="farm-ips-brick"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# read file to array
msg "${GREEN}read file to array${NOFORMAT} .. "
while IFS= read -r line; do
    echo "Text read from file: $line"
    array=("${array[@]}" "$line")
done < ${FILE_NAME}

# print array
msg "${GREEN}print array${NOFORMAT} .. "
for i in "${array[@]}"
do
   echo "$i"
done

msg "${GREEN}format and mount the brick${NOFORMAT} .. "

for i in "${array[@]}"
do
   msg "${RED}$i-${GREEN}peer storage status${NOFORMAT} .. "
   DEVICE=$(ssh centos@$i lsblk -o NAME,SIZE  | grep 7T | awk '{print $1}')
   echo $DEVICE
   array_brick=("${array_brick[@]}" "$DEVICE")
done

# for loop array_brick
msg "${GREEN}print array_brick${NOFORMAT} .. "
for i in "${array_brick[@]}"
do
   echo "$i" > device_file.txt
done

for i in "${array[@]}"
do
   echo "$i"
   msg "${GREEN}read file to array${NOFORMAT} .. "
   while IFS= read -r line; do
      echo "ssh centos@$i /dev/$line"
      # format and mount the brick
      msg "${RED}$i-${GREEN}mkfs.xfs -f /dev/${line}${NOFORMAT} .. "
      ssh centos@$i sudo mkfs.xfs -f /dev/${line}
      msg "${RED}$i-${GREEN}mkdir /mnt/brick${NOFORMAT} .. "
      ssh centos@$i sudo mkdir /mnt/brick
      msg "${RED}$i-${GREEN}mount /dev/${line} /mnt/brick${NOFORMAT} .. "
      ssh centos@$i sudo mount /dev/${line} /mnt/brick
      msg "${RED}$i-${GREEN}chown -R gluster:gluster /mnt/brick${NOFORMAT} .. "
      ssh centos@$i sudo chown -R gluster:gluster /mnt/brick
      msg "${RED}$i-${GREEN}df -h${NOFORMAT} .. "
      ssh centos@$i df -h
   done < device_file.txt
done

msg "${RED}---------------------------------------- END ----------------------------------------${NOFORMAT}"

   ssh centos@192.168.10.18 sudo gluster volume create test disperse 3 redundancy 1 \
	   ${arr[0]}

   exit
