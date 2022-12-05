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
sudo apt update
sudo snap install --channel=3.2 maas

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
export MAAS_DBPASS="2001May09"
export MAAS_GMAIL="khkraining@falinux.com"

sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo  bash -c "echo 'host    maas      falinux    0/0       md5' >> /etc/postgresql/12/main/pg_hba.conf"

echo | sudo maas init region+rack --database-uri "postgres://${MAAS_DBUSER}:${MAAS_DBPASS}@localhost/${MAAS_DBNAME}"

#--------------------------------------------------------------------------------
msg "#4-${GREEN}Init MAAS${NOFORMAT} .. "

export MAAS_USER="falinux"

sudo maas createadmin --username ${MAAS_USER} --password ${MAAS_DBPASS} --email $MAAS_GMAIL

sudo maas apikey --username ${MAAS_USER}
sudo maas login ${MAAS_USER} http://localhost:5240/MAAS/api/2.0/

sudo maas ${MAAS_USER} --help

#--------------------------------------------------------------------------------
msg "#5-${GREEN}MAAS generic setting${NOFORMAT}"

KERNEL_OPTS="console=tty0 console=ttyS0,115200n8"

sudo maas ${MAAS_USER} maas set-config name=enable_analytics value=false
sudo maas ${MAAS_USER} maas set-config name=maas_name value=${MAAS_USER}
sudo maas ${MAAS_USER} maas set-config name=kernel_opts value=${KERNEL_OPTS}
sudo maas ${MAAS_USER} maas set-config name=completed_intro value=true

msg "#6-${GREEN}MAAS dhcp setting${NOFORMAT}"
# input user string 

RACK_FABRIC_ID=$(sudo maas ${MAAS_USER} subnet read "10.10.0.0/16" | jq -r -M ".vlan.fabric_id") 
RACK_VID=$(sudo maas ${MAAS_USER} subnet read "10.10.0.0/16" | jq -r -M ".vlan.vid")
RACK_PRIMARY_ID=$(sudo maas ${MAAS_USER} rack-controllers read | jq -r -M ".[].system_id") 


msg "${BLUE}"
echo "===> RACK_FABRIC_ID=${RACK_FABRIC_ID}"
echo "===> RACK_VID=${RACK_VID}"
echo "===> RACK_PRIMARY_ID=${RACK_PRIMARY_ID}"
msg "${NOFORMAT}"

sudo maas ${MAAS_USER} subnet update 10.10.0.0/16 gateway_ip=10.10.0.1
sudo maas ${MAAS_USER} ipranges create type=dynamic start_ip=10.10.100.100 end_ip=10.10.100.200
sudo maas ${MAAS_USER} vlan update \
                 "${RACK_FABRIC_ID}" \
                 "${RACK_VID}" \
                 dhcp_on=True \
                 primary_rack="${RACK_PRIMARY_ID}"

sudo maas ${MAAS_USER} maas set-config name=upstream_dns value="8.8.8.8"

msg "#8-${GREEN}Machine ssh public key${NOFORMAT}"
cat ~/.ssh/id_rsa.pub