FROM debian:bookworm-slim

ARG REPO="itsmng"
ARG VERSION=1.6.1

RUN apt update && apt dist-upgrade -y && \
        apt install -y apache2 wget php php-fpm php-mysql php-intl php-mbstring php-gd php-ldap php-simplexml php-curl php-apcu php-xmlrpc && \
        a2enmod proxy_fcgi setenvif && \
        a2enconf php8.2-fpm && \
        apt-get -y clean && \
	    rm -r /var/lib/apt/lists/* && \
        rm /etc/apache2/sites-enabled/000-default.conf

RUN cd /var/www && \
        wget -q "https://github.com/$REPO/itsm-ng/releases/download/v$VERSION/itsm-ng-$VERSION.tgz" && \
        tar -xf itsm-ng-${VERSION}.tgz && \
        rm -rf itsm-ng-${VERSION}.tgz && \
        chown -R www-data:www-data /var/www/itsm-ng

COPY files/itsm-ng.conf /etc/apache2/sites-enabled/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /etc/init.d/php8.2-fpm start && apachectl -D FOREGROUND
