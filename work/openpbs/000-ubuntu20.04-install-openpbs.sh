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


# package install
#msg "#1-${GREEN}package install${NOFORMAT} .. "
#sudo apt install -y gcc make libtool libhwloc-dev libx11-dev \
#                    libxt-dev libedit-dev libical-dev ncurses-dev \
#                    perl postgresql-server-dev-all postgresql-contrib \
#                    unzip python3-dev tcl-dev tk-dev swig libexpat-dev \
#                    libssl-dev libxext-dev libxft-dev autoconf automake g++
#
#sudo apt install -y expat libedit2 postgresql python3 postgresql-contrib \
#                    sendmail-bin sudo tcl tk libical3 postgresql-server-dev-all
#
#wget https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz
#
#tar xzf Python-3.5.9.tgz
#
#cd Python-3.5.9
#sudo ./configure --enable-optimizations
#sudo make altinstall
#cd -

#sudo rm /usr/bin/python3
#sudo ln -s /usr/local/bin/python3.5 /usr/bin/python3

OPENPBS_TAR_GZ="v20.0.0.tar.gz"
OPENPBS_MASTER="master.zip"

if [ ! -f ${OPENPBS_TAR_GZ} ]; then
#  wget https://github.com/openpbs/openpbs/archive/refs/tags/v20.0.0.tar.gz
  wget https://github.com/openpbs/openpbs/archive/refs/heads/master.zip
  tar xzf ${OPENPBS_TAR_GZ}
fi

#unzip ${OPENPBS_MASTER}
#
#cd openpbs-master
#./autogen.sh
#./configure --prefix=/opt/pbs
#make -j$(nproc)
#sudo make install
#sudo /opt/pbs/libexec/pbs_postinstall
#sudo sed -i 's/^PBS_SERVER=.*/PBS_SERVER=local/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SERVER=.*/PBS_START_SERVER=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SCHED=.*/PBS_START_SCHED=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_COMM=.*/PBS_START_COMM=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_MOM=.*/PBS_START_MOM=0/g' /etc/pbs.conf

sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
sudo systemctl stop pbs
sudo systemctl start pbs
sudo systemctl status pbs

exit

cd ${OPENPBS_DIR} 
./autogen.sh
./configure --prefix=/opt/openpbs
make 
sudo make install
sudo /opt/openpbs/libexec/pbs_postinstall
#sudo sed -i 's/^PBS_SERVER=.*/PBS_SERVER=local/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SERVER=.*/PBS_START_SERVER=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SCHED=.*/PBS_START_SCHED=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_COMM=.*/PBS_START_COMM=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_MOM=.*/PBS_START_MOM=0/g' /etc/pbs.conf

sudo chmod 4755 /opt/openpbs/sbin/pbs_iff /opt/openpbs/sbin/pbs_rcp
sudo systemctl stop pbs
sudo systemctl start pbs
sudo systemctl status pbs

rm -rf ${OPENPBS_DIR}
rm -rf ${OPENPBS_TAR_GZ}

exit


wget https://github.com/openpbs/openpbs/archive/refs/heads/master.zip
unzip master.zip
cd openpbs-master
./autogen.sh
./configure --prefix=/opt/pbs
make -j$(nproc)
sudo make install
sudo /opt/pbs/libexec/pbs_postinstall
#sudo sed -i 's/^PBS_SERVER=.*/PBS_SERVER=local/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SERVER=.*/PBS_START_SERVER=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SCHED=.*/PBS_START_SCHED=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_COMM=.*/PBS_START_COMM=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_MOM=.*/PBS_START_MOM=0/g' /etc/pbs.conf

sudo chmod 4755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp
sudo systemctl stop pbs
sudo systemctl start pbs
sudo systemctl status pbs

exit

./autogen.sh
./configure --prefix=/opt/openpbs
make -j$(nproc)
sudo make install
sudo /opt/openpbs/libexec/pbs_postinstall
#sudo sed -i 's/^PBS_SERVER=.*/PBS_SERVER=local/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SERVER=.*/PBS_START_SERVER=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_SCHED=.*/PBS_START_SCHED=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_COMM=.*/PBS_START_COMM=1/g' /etc/pbs.conf
sudo sed -i 's/^PBS_START_MOM=.*/PBS_START_MOM=0/g' /etc/pbs.conf

sudo chmod 4755 /opt/openpbs/sbin/pbs_iff /opt/openpbs/sbin/pbs_rcp
sudo systemctl stop pbs
sudo systemctl start pbs
sudo systemctl status pbs

# end of file
msg "${RED}------------------------------ END ------------------------------${NOFORMAT} .. "

exit


# install the prerequisite packages for enabling openPBS on CentOS 7
msg "#1-${GREEN}install the prerequisite packages for enabling openPBS on CentOS 7${NOFORMAT} .. "
for i in "${array[@]}"
    ssh centos@$i ls -al
do



