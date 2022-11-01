
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
   # or do whatever with individual element of the array
done


# read file line by line to array
# https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-into-an-array-in-bash
# https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-into-an-array-in-bash/10929511#10929511
# https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-into-an-array-in-bash/10929511#10929511
# https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-into-an-array-in-bash/10929511#10929511
while IFS= read -r line
do
  echo "$line"
done < "file.txt"

# declaring array list and index iterator
declare -a array=()
i=0

# reading file line by line
while IFS= read -r line
do
  # adding line to array
  array[i]="$line"
  # incrementing index
  ((i++))
done < "fram-ips"




# getting device name
DEVICE=$(lsblk -o NAME,SIZE | grep 100G | awk '{print $1}')

echo $DEVICE
#format device to xfs
mkfs.xfs /dev/$DEVICE

# string to array
IFS=',' read -r -a array <<< "$DEVICE"


msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# install glusterfs for centos7
msg "${GREEN}Install glusterfs for centos7${NOFORMAT} .. "

sudo yum install centos-release-gluster -y

sudo yum install glusterfs-server -y

sudo systemctl enable glusterd

sudo systemctl start glusterd

# glusterfs add brick
msg "${GREEN}glusterfs add brick${NOFORMAT} .. "

# gluster brick add <VOLNAME> <BRICK> [force]
# gluster volume add-brick <VOLNAME> <BRICK> [replica <COUNT>] [force]
# gluster volume add-brick <VOLNAME> <BRICK> [stripe <COUNT>] [force]
# gluster volume add-brick <VOLNAME> <BRICK> [replica <COUNT>] [stripe <COUNT>] [force]

# gluster volume info
# glusterfs device format

# format and mount the brick
# mkfs.xfs -f /dev/sdb
# mkdir -p /gluster/brick1
# mount /dev/sdb /gluster/brick1

# xargs array
# https://stackoverflow.com/questions/1527049/join-elements-of-an-array

