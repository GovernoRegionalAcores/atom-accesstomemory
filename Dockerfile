FROM php:5-fpm

ENV ATOM_HOST=127.0.0.1

ENV ATOM_DIR=/usr/share/nginx/atom

ENV ATOM_VERSION=2.3.0

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
	nginx \
	gearman-job-server \
	software-properties-common

RUN docker-php-ext-install pdo pdo_mysql calendar
RUN pecl install apcu-4.0.11 \
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN cd /etc/apt \
    && echo "deb http://packages.elasticsearch.org/elasticsearch/1.7/debian stable main" >> sources.list \
    && apt-get update \
    && apt-get install -y elasticsearch

RUN wget https://storage.accesstomemory.org/releases/atom-$ATOM_VERSION.tar.gz
RUN mkdir /usr/share/nginx/atom \
	&& tar xzf atom-2.3.0.tar.gz -C /usr/share/nginx/atom --strip 1

RUN chown -R www-data:www-data /usr/share/nginx/atom

#Settings

ADD bootstrap.php /bootstrap.php

COPY atom.conf /etc/php5/fpm/pool.d/atom.conf
COPY atom /etc/nginx/sites-available/atom
RUN ln -sf /etc/nginx/sites-available/atom /etc/nginx/sites-enabled/atom
RUN rm /etc/nginx/sites-enabled/default

COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR $ATOM_DIR

CMD ["nginx", "-g", "daemon off;"]





