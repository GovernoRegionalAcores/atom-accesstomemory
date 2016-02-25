#!/bin/bash
set -e

cd $ATOM_DIR && chown www-data:www-data . -R && chmod -R u+rX .

update-rc.d elasticsearch defaults 95 10
/etc/init.d/elasticsearch start

#DATABASE INIT/CONFIG
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, LOCK TABLES ON $DB_NAME.* TO '$DB_USER' IDENTIFIED BY '$DB_PW';"

tables=`mysql -h $MYSQL_PORT_3306_TCP_ADDR -u$DB_USER -p$DB_PW -s -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME';"`

if [ "$tables" -eq "0" ]; then
  rm /var/www/config/config.php
else
  sed -i "s@'dsn' => 'mysql:dbname=atom;port=3306'@'dsn' => 'mysql:dbname=$DB_NAME;host=$MYSQL_PORT_3306_TCP_ADDR;port=3306'@g" /var/www/config/config.php
  sed -i "s@'username' => 'root',@'username' => '$DB_USER', 'password'=>'$DB_PW'@g" /var/www/config/config.php
mkdir $ATOM_DIR/log && cd $ATOM_DIR/log && touch qubit_cli.log && touch qubit_prod.log && chown -R www-data:www-data $ATOM_DIR/log && chmod 777 qubit_prod.log; (sleep 10; cd $ATOM_DIR && php symfony search:populate) &
fi
#END - DATABASE INIT/CONFIG

exec "$@"
