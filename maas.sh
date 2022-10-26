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

VER="1.0.11"

msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

#--------------------------------------------------------------------------------
# How to install MAAS : https://maas.io/docs/how-to-install-maas

msg "${GREEN}Cleanup MAAS${NOFORMAT} .. "
sudo snap remove maas maas-cli
sudo snap remove maas-test-db

msg "${GREEN}Cleanup Postgresql${NOFORMAT} .. "
sudo apt autoremove postgresql postgresql-12 postgresql-client-12 postgresql-client-common postgresql-common -y
dpkg --list |grep "^rc" | cut -d " " -f 3 | sudo DEBIAN_FRONTEND=noninteractiv xargs dpkg --purge 

#--------------------------------------------------------------------------------

msg "#1-${GREEN}Install MAAS${NOFORMAT} .. "
#sudo snap install --channel=2.9 maas
sudo apt update
sudo snap install --channel=3.2 maas
#sudo snap refresh --channel=3.2 maas

#--------------------------------------------------------------------------------
# Install postgresql and jq 

msg "#2-${GREEN}Install postgresql${NOFORMAT} .."

sudo apt update -y 
sudo apt install -y postgresql
sudo apt install -y jq

#--------------------------------------------------------------------------------

msg "#3-${GREEN}MAAS DATABASE init${NOFORMAT} .. "

export MAAS_DBUSER="maas"
export MAAS_DBNAME="maas-db"
export MAAS_DBPASS="qwer1234"
#echo -n "Password MAAS_DBPASS: "
#read -rs MAAS_DBPASS
#echo -n "Again MAAS_DBPASS: "
#read -rs AGAIN_MAAS_DBPASS
#if [ "${MAAS_DBPASS}" != "${AGAIN_MAAS_DBPASS}" ]; then
#  msg "${RED}No match passsword${NOFORMAT}"
#fi

sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo  bash -c "echo 'host    maas      falinux    0/0       md5' >> /etc/postgresql/12/main/pg_hba.conf"
#sudo -u postgres psql --no-align -q -f /tmp/psql_script_temp.sql &> /tmp/psql_log.txt && cat /tmp/psql_log.txt

#sudo  bash -c "echo 'http://localhost:5240/MAAS' | maas init region+rack --database-uri 'postgres://${MAAS_DBUSER}:${MAAS_DBPASS}@localhost/${MAAS_DBNAME}' "
echo | sudo maas init region+rack --database-uri "postgres://${MAAS_DBUSER}:${MAAS_DBPASS}@localhost/${MAAS_DBNAME}"

#--------------------------------------------------------------------------------
msg "#4-${GREEN}Init MAAS${NOFORMAT} .. "

sudo maas createadmin --username falinux --password qwer1234 --email khkraining@falinux.com

sudo maas apikey --username falinux
sudo maas login falinux http://localhost:5240/MAAS/api/2.0/

sudo maas falinux --help

#--------------------------------------------------------------------------------
msg "#5-${GREEN}MAAS generic setting${NOFORMAT}"

sudo maas falinux maas set-config name=enable_analytics value=false
sudo maas falinux maas set-config name=maas_name value='falinux'
sudo maas falinux maas set-config name=kernel_opts value='console=tty0 console=ttyS0,115200n8'
sudo maas falinux maas set-config name=completed_intro value=true

msg "#6-${GREEN}MAAS dhcp setting${NOFORMAT}"
dd
# input user string 

#--------------------------------------------------------------------------------
# setting 10.10.0.0/16
#RACK_FABRIC_ID=$(sudo maas falinux subnet read "10.10.0.0/16" | jq -r -M ".vlan.fabric_id") 
#RACK_VID=$(sudo maas falinux subnet read "10.10.0.0/16" | jq -r -M ".vlan.vid")
#RACK_PRIMARY_ID=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 
#
#
#echo "RACK_FABRIC_ID=${RACK_FABRIC_ID}"
#echo "RACK_VID=${RACK_VID}"
#echo "RACK_PRIMARY_ID=${RACK_PRIMARY_ID}"
#
#sudo maas falinux subnet update 10.10.0.0/16 gateway_ip=10.10.0.1
#sudo maas falinux ipranges create type=dynamic start_ip=10.10.100.100 end_ip=10.10.100.200
#sudo maas falinux vlan update \
#                 "${RACK_FABRIC_ID}" \
#                 "${RACK_VID}" \
#                 dhcp_on=True \
#                 primary_rack="${RACK_PRIMARY_ID}"
#
#--------------------------------------------------------------------------------

#RACK_FABRIC_ID_0=$(sudo maas falinux subnet read "10.20.0.0/16" | jq -r -M ".vlan.fabric_id") 
#RACK_VID_0=$(sudo maas falinux subnet read "10.20.0.0/16" | jq -r -M ".vlan.vid")
#RACK_PRIMARY_ID_0=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 
#
#echo "RACK_FABRIC_ID=${RACK_FABRIC_ID_0}"
#echo "RACK_VID=${RACK_VID_0}"
#echo "RACK_PRIMARY_ID=${RACK_PRIMARY_ID_0}"
#
#sudo maas falinux subnet update 10.20.0.0/16 gateway_ip=10.20.0.1
#sudo maas falinux ipranges create type=dynamic start_ip=10.20.100.100 end_ip=10.20.100.200
#sudo maas falinux vlan update \
#                 "${RACK_FABRIC_ID_0}" \
#                 "${RACK_VID_0}" \
#                 dhcp_on=True \
#                 primary_rack="${RACK_PRIMARY_ID_0}"

RACK_FABRIC_ID=$(sudo maas falinux subnet read "192.168.0.0/16" | jq -r -M ".vlan.fabric_id") 
RACK_VID=$(sudo maas falinux subnet read "192.168.0.0/16" | jq -r -M ".vlan.vid")
RACK_PRIMARY_ID=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 

sudo maas falinux subnet update 192.168.0.0/16 gateway_ip=192.168.10.1 
sudo maas falinux ipranges create type=dynamic start_ip=192.168.10.100 end_ip=192.168.10.200 
sudo maas falinux vlan update \
                 "${RACK_FABRIC_ID}" \
                 "${RACK_VID}" \
                 dhcp_on=True \
                 primary_rack="${RACK_PRIMARY_ID}"

RACK_FABRIC_ID_0=$(sudo maas falinux subnet read "192.168.101.0/16" | jq -r -M ".vlan.fabric_id") 
RACK_VID_0=$(sudo maas falinux subnet read "192.168.101.0/16" | jq -r -M ".vlan.vid")
RACK_PRIMARY_ID_0=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 

echo "RACK_FABRIC_ID=${RACK_FABRIC_ID_0}"
echo "RACK_VID=${RACK_VID_0}"
echo "RACK_PRIMARY_ID=${RACK_PRIMARY_ID_0}"

sudo maas falinux subnet update 192.168.101.0/24 gateway_ip=192.168.101.1
sudo maas falinux ipranges create type=dynamic start_ip=192.168.101.100 end_ip=192.168.101.200
sudo maas falinux vlan update \
                 "${RACK_FABRIC_ID_0}" \
                 "${RACK_VID_0}" \
                 dhcp_on=True \
                 primary_rack="${RACK_PRIMARY_ID_0}"
#--------------------------------------------------------------------------------
# https://maas.io/docs/how-to-use-the-maas-cli

sudo maas falinux maas set-config name=upstream_dns value="8.8.8.8"

#--------------------------------------------------------------------------------
# https://maas.io/docs/advanced-cli-tasks

#--------------------------------------------------------------------------------

 sudo apt install haproxy

msg "#8-${GREEN}Machine ssh public key${NOFORMAT}"
cat ~/.ssh/id_rsa.pub

#--------------------------------------------------------------------------------

#sudo maas status

#echo "insert enter"
#read -r A
#echo "${A}"

#sudo snap install maas-test-db
#sudo maas init region+rack --database-uri maas-test-db:///
#echo ""
#echo ""

#If you want to configure external authentication or use
#MAAS with Canonical RBAC, please run
#
#  sudo maas configauth
#
#To create admins when not using external authentication, run
#
#  sudo maas createadmin
#
#To enable TLS for secured communication, please run
#
#  sudo maas config-tls enable

#-------------------------------------------------------------------------------
#sudo maas createadmin --username=falinux --email=khkraining@falinux.com

#Username: admin
#Password: 
#Again: 
#Email: khkraining@falinux.com
#Import SSH keys [] (lp:user-id or gh:user-id): gh:admin


#msg "#3-${GREEN}Install postgresql${NOFORMAT}"

#sudo apt update -y 
#
#sudo apt install -y postgresql

#sudo maas-test-db.qsql


#MAAS_DBUSER="maas"
#MAAS_DBNAME="maas-db"
#echo -n "Password MAAS_DBPASS: "
#read -rs MAAS_DBPASS
##echo -n "Again MAAS_DBPASS: "
##read -rs AGAIN_MAAS_DBPASS
##if [ "${MAAS_DBPASS}" != "${AGAIN_MAAS_DBPASS}" ]; then
##  msg "${RED}No match passsword${NOFORMAT}"
##fi
#
#sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
#
#sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
#
#HOSTNAME="localhost"
#sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME"

#--------------------------------------------------------------------------------
# debug log
# /var/snap/maas/common/log/rackd.log

#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Install tftpd-hpa 

#msg "#3-${GREEN}Install tftpd-hpa${NOFORMAT} .. "
#
#sudo apt install tftpd-hpa
#
## This will also a lot of cruft in the directory, perhaps that's fixable with other 
## wget options but this gets files and direcotries you need.
## You can clean up cruft
#sudo mkdir /srv/tftp
#cd /srv/tftp
#sudo wget -nH -r --cut-dirs=8 http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/
#sudo rm -f *.gif index.html* MANIFEST* MD5SUMS* SHA*
#cd -
#
## Now we need to set permissions and ownership of the files
#sudo chmod -R 777 /srv/tftp/
#sudo chown -R nobody: /srv/tftp/
#
## Next, make sure TFTPD can see the right directory by pointing
#cat /etc/default/tftpd-hpa

#--------------------------------------------------------------------------------
# 18:c0:4d:0e:73:50 
# 192.168.10.103