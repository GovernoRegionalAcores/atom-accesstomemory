FROM php:5-fpm

ENV ATOM_DIR=/usr/share/nginx/atom

ENV GIT_BRANCH=stable/2.3.x

ENV FOP_HOME /usr/share/fop-2.1

RUN apt-get update && apt-get install -y openjdk-7-jre-headless \
	wget \
	php5-cli \
	php5-fpm \
	php5-curl \
	php5-xsl \
	php5-json \
	php5-ldap \
	php-apc \
	php5-readline \
	mysql-client \
	php5-mysql \
	imagemagick \
	ghostscript \
	poppler-utils \
	nginx

RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN cd /etc/apt \
    && echo "deb http://packages.elasticsearch.org/elasticsearch/1.7/debian stable main" >> sources.list \
    && apt-get update \
    && apt-get install -y elasticsearch

RUN wget https://storage.accesstomemory.org/releases/atom-2.3.0.tar.gz
RUN mkdir /usr/share/nginx/atom \
	&& tar xzf atom-2.3.0.tar.gz -C /usr/share/nginx/atom --strip 1

RUN chown -R www-data:www-data /usr/share/nginx/atom
RUN chmod o= /usr/share/nginx/atom

#Settings
RUN mv $ATOM_DIR/apps/qubit/config/settings.yml.tmpl $ATOM_DIR/apps/qubit/config/settings.yml
RUN sed -i "s@default_culture:        en@default_culture:        pt@g" $ATOM_DIR/apps/qubit/config/settings.yml
RUN sed -i "s@America/Vancouver@Atlantic/Azores@g" $ATOM_DIR/apps/qubit/config/settings.yml
ADD descriptionUpdatesSuccess.php $ATOM_DIR/apps/qubit/modules/search/templates/descriptionUpdatesSuccess.php
ADD bootstrap.php /bootstrap.php

COPY atom.conf /etc/php5/fpm/pool.d/atom.conf
COPY atom /etc/nginx/sites-available/atom
RUN ln -sf /etc/nginx/sites-available/atom /etc/nginx/sites-enabled/atom
RUN rm /etc/nginx/sites-enabled/default
RUN sed -i "s@memory_limit = 128M@memory_limit = 1024M@g" /etc/php5/fpm/php.ini

COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]





