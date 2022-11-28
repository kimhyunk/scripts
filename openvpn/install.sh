#!/usr/bin/env bash


OVPN_DATA="${HOME}/.openvpn/config"
DOMAIN="udp://www.falinux.dev"
KEY_NAME="falinux"


docker stop openvpn
docker rm openvpn

sudo rm -rf ${OVPN_DATA}

docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u ${DOMAIN}

sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${KEY_NAME} nopass

docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${KEY_NAME} > ${KEY_NAME}.ovpn

docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
