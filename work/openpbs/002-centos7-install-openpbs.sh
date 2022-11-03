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
OPENPBS_DIR="openpbs-20.0.0"
#OPENPBS_DIR="openpbs-master"
#OPENPBS_MASTER_ZIP="master.zip"

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

# Download v20.0.0.tar.gz
msg "#1-${GREEN}Download v20.0.0.tar.gz${NOFORMAT} .. "
# if v20.0.0.tar.gz file not exist
if [ ! -f ${OPENPBS_DIR} ]; then
  wget https://github.com/openpbs/openpbs/archive/refs/tags/v20.0.0.tar.gz
  tar -xvf v20.0.0.tar.gz
#  wget https://github.com/openpbs/openpbs/archive/refs/heads/master.zip
#  unzip master.zip
fi

# copy v20.0.0.tar.gz to all nodes
msg "#2-${GREEN}copy v20.0.0.tar.gz to all nodes${NOFORMAT} .. "
for i in "${array[@]}"
do
  if [ -d ${OPENPBS_DIR} ]; then
    msg "---${BLUE}copy node ip:$i${NOFORMAT} .. "
    scp -r ${OPENPBS_DIR} centos@${i}:/home/centos > /dev/null
  fi
done

# Generate the configure script and Makefiles
msg "#3-${GREEN}Generate the configure script and Makefiles${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}autogen.sh node ip:$i${NOFORMAT} .. "
  ssh centos@$i "cd ${OPENPBS_DIR} && ./autogen.sh" > /dev/null
done

# display the configure script and Makefiles
msg "#4-${GREEN}display the configure script and Makefiles${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}autogen.sh node ip:$i${NOFORMAT} .. "
  ssh centos@$i "cd ${OPENPBS_DIR} && ./configure --help" 
done

# configure the build for the OpenPBS software
msg "#5-${GREEN}configure the build for the OpenPBS software${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}configure node ip:$i${NOFORMAT} .. "
  ssh centos@$i "cd ${OPENPBS_DIR} && ./configure --prefix=/opt/openpbs" > /dev/null
done

# build the OpenPBS software
msg "#6-${GREEN}build the OpenPBS software${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}make node ip:$i${NOFORMAT} .. "
  ssh centos@$i "cd ${OPENPBS_DIR} && make -j$(nproc)"
done

# install the OpenPBS software
msg "#7-${GREEN}install the OpenPBS software${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}make install node ip:$i${NOFORMAT} .. "
  ssh centos@$i "cd ${OPENPBS_DIR} && sudo make install"
done

# configure PBS by exectuing the pbs_postinstall script
msg "#8-${GREEN}configure PBS by exectuing the pbs_postinstall script${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}pbs_postinstall node ip:$i${NOFORMAT} .. "
  ssh centos@$i "sudo /opt/openpbs/libexec/pbs_postinstall"
done

# edit /etc/pbs.confg to set compute node
msg "#9-${GREEN}edit /etc/pbs.confg to set compute node${NOFORMAT} .. "
for i in "${array[@]}"
do
  #autogen.sh is a script that generates the configure script and Makefiles
  msg "---${BLUE}edit /etc/pbs.confg node ip:$i${NOFORMAT} .. "
  ssh centos@$i "sudo sed -i 's/^PBS_SERVER=.*/PBS_SERVER=192.168.10.29/g' /etc/pbs.conf"
  ssh centos@$i "sudo sed -i 's/^PBS_START_SERVER=.*/PBS_START_SERVER=0/g' /etc/pbs.conf"
  ssh centos@$i "sudo sed -i 's/^PBS_START_SCHED=.*/PBS_START_SCHED=0/g' /etc/pbs.conf"
  ssh centos@$i "sudo sed -i 's/^PBS_START_COMM=.*/PBS_START_COMM=0/g' /etc/pbs.conf"
  ssh centos@$i "sudo sed -i 's/^PBS_START_MOM=.*/PBS_START_MOM=1/g' /etc/pbs.conf"

  ssh centos@$i "cat /etc/pbs.conf"
done

# some file permission must be modified to add SUID privileges
msg "#10-${GREEN}some file permission must be modified to add SUID privileges${NOFORMAT} .. "
for i in "${array[@]}"
do
  ssh centos@$i "sudo chmod 4755 /opt/openpbs/sbin/pbs_iff /opt/openpbs/sbin/pbs_rcp"
done

# compute server firewalld
msg "#11-${GREEN}compute server firewalld${NOFORMAT} .. "
for i in "${array[@]}"
do
  ssh centos@$i "sudo firewall-cmd --zone=public --add-port=17001/tcp --permanent"
  ssh centos@$i "sudo firewall-cmd --zone=public --add-port=15001-15004/tcp --permanent"
  ssh centos@$i "sudo firewall-cmd --reload"
done

# start the PBS services
msg "#11-${GREEN}start the PBS services${NOFORMAT} .. "
for i in "${array[@]}"
do
  ssh centos@$i "sudo systemctl stop pbs"
  ssh centos@$i "sudo systemctl start pbs"
  ssh centos@$i "sudo systemctl status pbs"
done

# comptue server pbsnodes registration
msg "#12-${GREEN}comptue server pbsnodes registration${NOFORMAT} .. "
for i in "${array[@]}"
do
  ssh centos@$i "qmgr -c 'create node $i'"
  ssh centos@$i "pbsnodes -a"
done


# end of file
msg "${RED}------------------------------ END ------------------------------${NOFORMAT} .. "

exit


