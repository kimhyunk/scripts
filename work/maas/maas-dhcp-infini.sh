RACK_FABRIC_ID=$(sudo maas falinux subnet read "192.168.0.0/24" | jq -r -M ".vlan.fabric_id") 
RACK_VID=$(sudo maas falinux subnet read "192.168.0.0/24" | jq -r -M ".vlan.vid")
RACK_PRIMARY_ID=$(sudo maas falinux rack-controllers read | jq -r -M ".[].system_id") 

sudo maas falinux subnet update 192.168.0.0/24 gateway_ip=192.168.101.1 
sudo maas falinux ipranges create type=dynamic start_ip=192.168.101.100 end_ip=192.168.101.200 
sudo maas falinux vlan update \
                 "${RACK_FABRIC_ID}" \
                 "${RACK_VID}" \
                 dhcp_on=True \
                 primary_rack="${RACK_PRIMARY_ID}"
