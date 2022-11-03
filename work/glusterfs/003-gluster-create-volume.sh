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

declare -a array_farm=()
FILE_NAME="farm-ips-brick"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

# read file to array
msg "${GREEN}read file to array${NOFORMAT} .. "
while IFS= read -r line; do
    echo "Text read from file: $line"
    array=("${array[@]}" "$line")
done < ${FILE_NAME}

## print array
#for farm_ip in "${array[@]}"
#do
#  msg "${BLUE}disk mounted, disk format ip=$farm_ip${NOFORMAT}" 
#  ssh centos@$farm_ip df -h | grep mnt
#  echo ""
#done

GLUSTER_DISPERSED_VOLUME="dispersed"
GLUSTER_DISTRIBUTED_DISPERSED_VOLUME="distributed-dispersed"

ssh centos@${array[0]} sudo gluster volume create ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME} disperse 3 redundancy 1 \
  ${array[0]}:/mnt/brick/sda \
  ${array[1]}:/mnt/brick/sdb \
  ${array[2]}:/mnt/brick/sdc \
  ${array[0]}:/mnt/brick/sdd \
  ${array[1]}:/mnt/brick/sdf \
  ${array[2]}:/mnt/brick/sdg \
  force

ssh centos@${array[0]} sudo gluster volume start ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME}

msg "${RED}---------------------------------------- END ----------------------------------------${NOFORMAT}"

exit

#--------------------------------------------------------------------------------
ssh centos@${array[0]} sudo gluster volume create ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME} disperse 3 redundancy 1 \
  ${array[0]}:/mnt/brick/sda \
  ${array[1]}:/mnt/brick/sdb \
  ${array[2]}:/mnt/brick/sdc \
  ${array[0]}:/mnt/brick/sdd \
  ${array[1]}:/mnt/brick/sdf \
  ${array[2]}:/mnt/brick/sdg \
  force

ssh centos@${array[0]} sudo gluster volume start ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME}
ssh centos@${array[0]} sudo gluster volume info

ssh centos@${array[0]} sudo gluster volume stop ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME} 
ssh centos@${array[0]} sudo gluster volume delete ${GLUSTER_DISTRIBUTED_DISPERSED_VOLUME} 

#--------------------------------------------------------------------------------
ssh centos@${array[0]} sudo gluster volume create ${GLUSTER_DISPERSED_VOLUME} disperse 3 redundancy 1 \
  ${array[0]}:/mnt/brick/sda \
  ${array[1]}:/mnt/brick/sdb \
  ${array[2]}:/mnt/brick/sdc \
  force

ssh centos@${array[0]} sudo gluster volume start ${GLUSTER_DISPERSED_VOLUME}
ssh centos@${array[0]} sudo gluster volume info

ssh centos@${array[0]} sudo gluster volume stop ${GLUSTER_DISPERSED_VOLUME} 
ssh centos@${array[0]} sudo gluster volume delete ${GLUSTER_DISPERSED_VOLUME} 