FROM reinblau/php-apache2

ENV ATOM_VERSION=2.2.1
ENV ATOM_DIR=/var/www

RUN apt-get update && apt-get install -y php5-cli php5-fpm php5-curl php5-mysql php5-xsl php5-json php5-ldap php-apc mysql-client ghostscript

RUN apt-get install openjdk-7-jre-headless -y \
    && wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN cd /etc/apt \
    && echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" >> sources.list \
    && apt-get update \
    && apt-get install -y elasticsearch
RUN update-rc.d elasticsearch defaults 95 10 \
    && /etc/init.d/elasticsearch start

RUN curl https://storage.accesstomemory.org/releases/atom-$ATOM_VERSION.tar.gz| tar -C $ATOM_DIR -xzf -

RUN cd $ATOM_DIR \
    && mv atom-$ATOM_VERSION /var/ \
    && cd /var/ \
    && mv www www2 \
    && mv atom-$ATOM_VERSION www

COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash", "/root/start.bash"]

