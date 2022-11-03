msg "#3-${GREEN}MAAS DATABASE init${NOFORMAT} .. "

export MAAS_DBUSER="maas"
export MAAS_DBNAME="maas-db"
export MAAS_DBPASS="2001May09"
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
