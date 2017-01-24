#!/bin/bash
set -e

#DATABASE INIT/CONFIG
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, LOCK TABLES ON $DB_NAME.* TO '$DB_USER' IDENTIFIED BY '$DB_PW';"

php /bootstrap.php $@

update-rc.d elasticsearch defaults 95 10
/etc/init.d/elasticsearch start

service php5-fpm start
exec "$@"
