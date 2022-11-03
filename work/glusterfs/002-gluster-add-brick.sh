#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

    msg "retrun_code=$?"
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
declare -a array_devices=()
FILE_NAME="farm-ips-brick"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# read file to array
msg "#1-${GREEN}read file to array${NOFORMAT} .. "
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

msg "#2-${GREEN}format and mount the brick${NOFORMAT} .. "
for i in "${array[@]}"
do
#   msg "${RED}$i-${GREEN}peer storage status${NOFORMAT} .. "
   DEVICE=$(ssh centos@$i lsblk -o NAME,SIZE  | grep 7T | awk '{print $1}')
#   echo $DEVICE
   array_brick=("${array_brick[@]}" "$DEVICE")
done

# for loop array_brick
msg "#3-${GREEN}print array_brick${NOFORMAT} .. "
for i in "${array_brick[@]}"
do
   echo "$i" > device_file.txt
done

# file to array
msg "#5-${GREEN}file to array${NOFORMAT} .. "
while IFS= read -r line; do
#    echo "Text read from file: $line"
    array_devices=("${array_devices[@]}" "$line")
done < device_file.txt

# for loop array_devices
msg "#6-${GREEN}format and mount the brick${NOFORMAT} .. "
for device_name in "${array_devices[@]}"
do
   for farm_ip in "${array[@]}"
   do
      if ssh centos@$farm_ip mount | grep $device_name > /dev/null; then
         msg "${BLUE}disk mounted, disk format ip=$farm_ip device=$device_name${NOFORMAT}" 
         ssh centos@$farm_ip df -h
         echo ""
         #ssh centos@$farm_ip sudo umount /dev/$device_name
      else
         msg "${RED}disk not mounted, disk format ip=$farm_ip device=$device_name${NOFORMAT}" 
         ssh centos@$farm_ip sudo mkfs.xfs -f /dev/$device_name > /dev/null
         ssh centos@$farm_ip sudo mkdir -p /mnt/brick/$device_name > /dev/null
         ssh centos@$farm_ip sudo mount /dev/$device_name /mnt/brick/$device_name > /dev/null
         ssh centos@$farm_ip sudo chown -R gluster:gluster /mnt/brick/$device_name > /dev/null
      fi
   done
   echo ""
done

msg "${RED}---------------------------------------- END ----------------------------------------${NOFORMAT}"

exit