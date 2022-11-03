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


RACK_FABRIC_ID=$(sudo maas falinux subnet read "192.168.0.0/16" | jq -r -M ".vlan.fabric_id") 
RACK_VID=$(sudo maas falinux subnet read "192.168.0.0/16" | jq -r -M ".vlan.vid")
RACK_PRIMARY_ID=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 

echo "RACK_FABRIC_ID=${RACK_FABRIC_ID}"
echo "RACK_VID=${RACK_VID}"
echo "RACK_PRIMARY_ID=${RACK_PRIMARY_ID}"

sudo maas falinux subnet update 192.168.0.0/16 gateway_ip=192.168.10.1 
sudo maas falinux ipranges create type=dynamic start_ip=192.168.10.100 end_ip=192.168.10.200 
sudo maas falinux vlan update \
                 "${RACK_FABRIC_ID}" \
                 "${RACK_VID}" \
                 dhcp_on=True \
                 primary_rack="${RACK_PRIMARY_ID}"

#--------------------------------------------------------------------------------
# https://maas.io/docs/how-to-use-the-maas-cli

sudo maas falinux maas set-config name=upstream_dns value="8.8.8.8"

#--------------------------------------------------------------------------------
# https://maas.io/docs/advanced-cli-tasks

#--------------------------------------------------------------------------------

# sudo apt install haproxy

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
