#!/bin/bash

export MYSQL_PASSWORD="zabbix123"

_file_marker="/var/lib/mysql/.mysql-configured"

if [ ! -f "$_file_marker" ]; then
    service mysql start
    mysql -u root -p"$MYSQL_PASSWORD" -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';" 
    mysql -u root -p"$MYSQL_PASSWORD" -e "create database zabbix charset utf8;"
    mysql -u root -p"$MYSQL_PASSWORD" -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
    mysql -u root -p"$MYSQL_PASSWORD" -e "flush privileges;"
    
    service mysql restart 
    
    echo "Importing Databases"    
    zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p'zabbix' -D zabbix

    ############### CONVERT TABLES CHARSET SCRIPT ##################
    DB="zabbix"
    CHARSET="utf8"
    COLL="utf8_bin"
    [-n "$DB"] || exit 1
    [-n "$CHARSET"] || CHARSET="utf8mb4"
    [-n "$COLL"] || COLL="utf8mb4_general_ci"
    echo $DB
    echo "ALTER DATABASE $DB CHARACTER SET $CHARSET COLLATE $COLL;"| mysql
    echo "USE $DB; SHOW TABLES;"| mysql -s | (
    while read TABLE; do
        echo $DB.$TABLE
        echo "ALTER TABLE $TABLE CONVERT TO CHARACTER SET $CHARSET COLLATE $COLL;"| mysql $DB
    done
    )
    ############### END OF CONVERT TABLES CHARSET SCRIPT ##################

    service mysql stop
    touch "$_file_marker"    
fi

#start all services 
service mysql start 
service zabbix-server start 
service zabbix-agent start 
service apache2 start 

# Block container exit
tail -f /dev/null
