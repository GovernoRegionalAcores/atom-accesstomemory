FROM ubuntu:22.04

RUN apt-get update && apt-get install software-properties-common wget -y

#ELASTICSEARCH
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-add-repository ppa:ondrej/php
RUN apt update
RUN apt install openjdk-8-jre-headless software-properties-common -y
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
RUN apt update
RUN apt install elasticsearch
#RUN service elasticsearch enable
RUN service elasticsearch start

#NGINX
RUN apt-get install nginx -y
RUN touch /etc/nginx/sites-available/atom
RUN ln -sf /etc/nginx/sites-available/atom /etc/nginx/sites-enabled/atom
RUN rm /etc/nginx/sites-enabled/default
ADD atom /etc/nginx/sites-available/atom
#RUN service nginx enable
RUN service nginx start

#PHP
RUN apt-get update && apt-get install -y php7.2-cli \
					php7.2-curl \
					php7.2-json \
					php7.2-ldap \
					php7.2-mysql \
					php7.2-opcache \
					php7.2-readline \
					php7.2-xml \
					php7.2-fpm \
					php7.2-mbstring \
					php7.2-xsl \
					php7.2-zip \
					php7.2-apcu \
					php-memcached \
					curl \
					mysql-client
			
ADD atom.conf /etc/php/7.2/fpm/pool.d/atom.conf

#RUN service php-fpm7.2 enable
#RUN service php7.2-fpm start
RUN rm /etc/php/7.2/fpm/pool.d/www.conf
RUN service php7.2-fpm start

#GEARMAN

RUN apt install gearman-job-server -y

RUN wget https://storage.accesstomemory.org/releases/atom-2.6.4.tar.gz
RUN mkdir /usr/share/nginx/atom
RUN tar xzf atom-2.6.4.tar.gz -C /usr/share/nginx/atom --strip 1
RUN chown -R www-data:www-data /usr/share/nginx/atom

COPY entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost/ || exit 1
ENTRYPOINT ["/entrypoint.sh"]


CMD ["nginx", "-g", "daemon off;"]
