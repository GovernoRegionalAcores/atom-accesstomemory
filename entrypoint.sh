#!/bin/bash
set -e

#DATABASE INIT/CONFIG
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, LOCK TABLES ON $DB_NAME.* TO '$DB_USER' IDENTIFIED BY '$DB_PW';"

#mkdir $ATOM_DIR
#chown -R www-data:www-data $ATOM_DIR

#php /bootstrap.php $@

#Worker $ FPM

#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
#__atom_root="$ATOM_DIR"


#Code base Internationalization
#sed -i "s@default_culture:        en@default_culture:        pt@g" $ATOM_DIR/apps/qubit/config/settings.yml
#sed -i "s@Add new@Adicionar novo@g" $ATOM_DIR/js/dialog.js
#sed -i "s@text: 'Cancel'@text: 'Cancelar'@g" $ATOM_DIR/js/dialog.js

chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

update-rc.d elasticsearch defaults 95 10
/etc/init.d/elasticsearch start


#Theming
createBackButton() {
	cd $1
	lastUlContent=`tac $2 | awk '/<\/ul>/ {p=1; split($0, a, "</ul>"); $0=a[1]}; /<ul>/ {p=0; split($0, a, "<ul>"); $0=a[2]; print; exit}; p' | tac`
	sed -i "s@`echo $lastUlContent`@<li><a onclick=\"window.history.back()\" class=\"c-btn\" title=\"Voltar ao início\">Voltar<\/a><\/li>`echo $lastUlContent`@g" $2
	sed -i "s@array('class' => 'c-btn')@array('class' => 'c-btn c-btn-submit')@g" $2
}
#createBackButton $ATOM_DIR/apps/qubit/modules/user/templates 'listSuccess.php'
#createBackButton $ATOM_DIR/plugins/qtAccessionPlugin/modules/accession/templates 'browseSuccess.php'
#createBackButton $ATOM_DIR/plugins/qtAccessionPlugin/modules/donor/templates 'browseSuccess.php'
#createBackButton $ATOM_DIR/apps/qubit/modules/physicalobject/templates 'browseSuccess.php'
#createBackButton $ATOM_DIR/apps/qubit/modules/rightsholder/templates 'browseSuccess.php'
#createBackButton $ATOM_DIR/plugins/qbAclPlugin/modules/aclGroup/templates 'listSuccess.php'
#createBackButton $ATOM_DIR/apps/qubit/modules/staticpage/templates/ 'listSuccess.php'
#createBackButton $ATOM_DIR/apps/qubit/modules/menu/templates/ 'listSuccess.php'

#sed -i "s@1800@3600@g" $ATOM_DIR/vendor/symfony/lib/config/config/factories.yml
#END - Theming

#OAI-PMH QDC & ORE
#sed -i "s@$metadataFormats = array(array('prefix'=>'oai_dc', 'namespace'=>'http://www.openarchives.org/OAI/2.0/oai_dc/', 'schema'=>'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'));@$metadataFormats = array(array('prefix'=>'oai_dc', 'namespace'=>'http://www.openarchives.org/OAI/2.0/oai_dc/', 'schema'=>'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'),array('prefix'=>'qdc', 'namespace'=>'http://purl.org/dc/terms/' ,'schema'=>'http://dublincore.org/schemas/xmls/qdc/2006/01/06/dcterms.xsd'),array('prefix'=>'ore', 'namespace'=>'http://www.w3.org/2005/Atom' ,'schema'=>'http://tweety.lanl.gov/public/schemas/2008-06/atom-tron.sch'));@g" $ATOM_DIR/lib/oai/QubitOai.class.php
#sed -i "s@\$metadataPrefix \!= 'oai_dc'@(\$metadataPrefix \!= 'oai_dc' AND \$metadataPrefix \!= 'qdc' AND \$metadataPrefix \!= 'ore')@g" $ATOM_DIR/plugins/arOaiPlugin/modules/arOaiPlugin/actions/indexAction.class.php

#OAI-PMH
correctDublinCoreDependency(){
	metadataTagContent=`tac $ATOM_DIR/plugins/arOaiPlugin/modules/arOaiPlugin/templates/$1 | awk '/<\/metadata>/ {p=1; split($0, a, "</metadata>"); $0=a[1]}; /<metadata>/ {p=0; split($0, a, "<metadata>"); $0=a[2]; print; exit}; p' | tac`
	sed -i "s@`echo $metadataTagContent`@<?php \$pluginName = \$_GET['metadataPrefix'] == 'oai_dc' ? 'sfDcPlugin' : (\$_GET['metadataPrefix'] == 'qdc' ? 'sfQdcPlugin' : 'sfOrePlugin'); ?><?php \$componentName = \$pluginName == 'sfDcPlugin' ? 'dc' : (\$pluginName == 'sfQdcPlugin' ? 'qdc' : 'ore'); ?><?php echo get_component(\$pluginName, \$componentName, array('resource' => `echo $2`)) ?>@g" $ATOM_DIR/plugins/arOaiPlugin/modules/arOaiPlugin/templates/$1
}
#correctDublinCoreDependency '_listRecords.xml.php' '$record'
#correctDublinCoreDependency '_getRecord.xml.php' '$informationObject'
#END - OAI-PMH



#service php7.0-fpm start
echo "Usage: (convenience shortcuts)"
case $1 in
    '')
        echo "Usage: (convenience shortcuts)"
        echo "  ./entrypoint.sh worker      Execute worker."
        echo "  ./entrypoint.sh fpm         Execute php-fpm."
        echo ""
        echo "You can also pass other commands:"
        echo "  ./entrypoint.sh bash"
        echo "  ./entrypoint.sh uptime"
        echo "  ./entrypoint.sh ls -l /"
        exit 0
        ;;
    'worker')
	echo "sou o worker"
        php /usr/share/nginx/atom/symfony jobs:worker &
#service php7.0-fpm start
#nginx -g "daemon off;"
#service php7.0-fpm start
        #exit 0
        ;;
    'nginx')
	service php7.0-fpm start
#	trap 'kill -INT $PID' TERM INT
#        php-fpm7.0 --allow-to-run-as-root &
#service php7.0-fpm start &
  #      PID=$!
  #      wait $PID
  #      trap - TERM INT
  #      wait $PID
  #      exit $?
exec "$@"
        ;;

esac
#Gearman
sed -i "s@PARAMS=\"--listen=localhost\"@PARAMS=\"--listen=* --port=4730\"@g" /etc/default/gearman-job-server
service gearman-job-server start
service memcached start
php /usr/share/nginx/atom/symfony jobs:worker &

#exec "${@}"
#echo "$@"

