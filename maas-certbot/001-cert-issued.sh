#!/usr/bin/env bash

set -Eeuo pipefail

trap - SIGINT SIGTERM ERR EXIT

cleanup () {

    msg "${RED}------------------------------ CLEANUP ------------------------------${NOFORMAT} .. "
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' \
    ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' \
    CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

setup_colors

VER="1.0.0"

# check sudo
if [ "$EUID" -ne 0 ]
  then msg "${RED}Please run as root${NOFORMAT}"
  exit
fi

# print version
msg "${GREEN}Script Ver${RED} ${VER}${NOFORMAT} .. "

DOMAIN="maas.falinux.dev"

# certbot by standalone
msg "${GREEN}#1-Install certbot by standalone${NOFORMAT} .. "
sudo certbot certonly --standalone -d ${DOMAIN}

CERTSDIR="/etc/letsencrypt/live/$DOMAIN"

cd /var/snap/maas/common

# need to copy certs where the snap can read them
sudo cp "$CERTSDIR"/{privkey,cert,chain}.pem .
maas config-tls enable privkey.pem cert.pem --cacert chain.pem --port 5443

# we don’t want to keep private key and certs around
sudo rm {privkey,cert,chain}.pem

exit

# Saving debug log to /var/log/letsencrypt/letsencrypt.log
# Requesting a certificate for maas.nemopai.com
# 
# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/maas.nemopai.com/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/maas.nemopai.com/privkey.pem
# This certificate expires on 2023-02-18.
# These files will be updated when the certificate renews.
# Certbot has set up a scheduled task to automatically renew this certificate in the background.
# 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# If you like Certbot, please consider supporting our work by:
#  * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
#  * Donating to EFF:                    https://eff.org/donate-le


msg "${GREEN}#1-Install certbot by webroot${NOFORMAT} .. "
#sudo certbot --webroot --installer apache -w /var/www/html/maas.nemopai.com -d maas.nemopai.com
#sudo certbot certonly --webroot


# certbot by webroot
msg "${GREEN}#2-Install certbot by webroot${NOFORMAT} .. "
#sudo certbot certonly --webroot -w /var/www/letsencrypt -d maas.nemopai.com:5443