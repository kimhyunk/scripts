#!/bin/bash -ex
# --- Start MAAS 1.0 script metadata ---
# name: 60-maas-000-mft-4.14.4-6-x86_64
# title: 60-maas-000-mft-4.14.4-6-x86_64
# description: mft-4.14.4-6-x86_64
# script_type: commissioning
# tags: configure_infiniband
# packages:
#  url: https://www.mellanox.com/downloads/MFT/mft-4.14.4-6-x86_64-deb.tgz
# recommission: False
# may_reboot: True
# --- End MAAS 1.0 script metadata ---
apt-get update -y
apt-get install gcc make dkms linux-headers-5.4.0-26-generic linux-headers-generic -y

$DOWNLOAD_PATH/mft-4.14.4-6-x86_64-deb/install.sh
mst start
mlxconfig --yes -d /dev/mst/mt4123_pciconf0 set LINK_TYPE_P1=2
reboot