FROM ubuntu:20.04

ENV ATOM_DIR=/usr/share/nginx/atom
ENV ATOM_VERSION=2.6.4
ENV LANG C.UTF-8

RUN apt-get update 
RUN apt-get install -y nginx

RUN service nginx restart

RUN apt-get install -y openjdk-8-jre-headless software-properties-common wget
#RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
#RUN add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.7/debian stable main"
RUN apt-get update && apt-get install -y curl
RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.deb
RUN dpkg -i elasticsearch-5.6.16.deb
#RUN apt-get update && apt-get instal l -y elasticsearch
RUN systemctl enable elasticsearch
RUN service elasticsearch start

ADD atom /etc/nginx/sites-available/atom
RUN ln -sf /etc/nginx/sites-available/atom /etc/nginx/sites-enabled/atom
RUN rm /etc/nginx/sites-enabled/default
ADD atom.conf /

RUN service elasticsearch restart
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y php7.2-cli \
					php7.2-curl \
					php7.2-json \
					php7.2-ldap \
					php7.2-mysql \
					php7.2-opcache \
					php7.2-readline \
					php-xml php7.2-xml \ 
					php7.2-fpm \
					php7.2-mbstring \
				#	php7.2-mcrypt \
					php7.2-xsl \
					php7.2-zip \
					php-memcache \
					php-apcu \
					php-dev \
					gearman-job-server \
					imagemagick \
					ghostscript \
					poppler-utils \
					ffmpeg \
					php-apcu \
					php-curl \
					php-pear

#RUN pecl install apcu_bc-beta
RUN apt-get install php7.2-apcu -y
#RUN echo "extension=apc.so" | tee > /etc/php/7.2/mods-available/apcu-bc.ini

RUN ln -sf /etc/php/7.2/mods-available/apcu-bc.ini /etc/php/7.2/fpm/conf.d/30-apcu-bc.ini
RUN ln -sf /etc/php/7.2/mods-available/apcu-bc.ini /etc/php/7.2/cli/conf.d/30-apcu-bc.ini

ADD atom.conf /etc/php/7.2/fpm/pool.d/atom.conf

RUN wget https://storage.accesstomemory.org/releases/atom-$ATOM_VERSION.tar.gz
RUN mkdir /usr/share/nginx/atom
RUN chown -R www-data:www-data /usr/share/nginx/atom
RUN tar xzf atom-$ATOM_VERSION.tar.gz -C /usr/share/nginx/atom --strip 1
RUN chown -R www-data:www-data /usr/share/nginx/atom
RUN apt-get install -y mysql-client php-mysql

COPY bootstrap.php /bootstrap.php
RUN update-alternatives --set  php /usr/bin/php7.2
RUN service php7.2-fpm start

COPY entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

WORKDIR $ATOM_DIR

CMD ["nginx", "-g", "daemon off;"]



