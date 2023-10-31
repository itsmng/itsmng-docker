FROM debian:bookworm-slim

ARG VERSION=1.5.1

RUN apt update && apt dist-upgrade -y && \
        apt install -y apache2 wget php php-fpm php-mysql php-intl php-mbstring php-gd php-ldap php-simplexml php-curl php-apcu php-xmlrpc && \
        a2enmod proxy_fcgi setenvif && \
        a2enconf php8.2-fpm && \
        apt-get -y clean && \
	    rm -r /var/lib/apt/lists/* && \
        rm /etc/apache2/sites-enabled/000-default.conf && \
        useradd itsm && \
        usermod -a -G itsm itsm && \
        sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
        chown -R itsm:itsm /var/log/apache2 && \
        chown -R itsm:itsm /var/run/apache2 && \
        touch /var/log/php8.2-fpm.log && \
        chown -R itsm:itsm /var/log/php8.2-fpm.log && \
        chown -R itsm:itsm /run/php

RUN cd /var/www && \
        wget -q "https://github.com/itsmng/itsm-ng/releases/download/v${VERSION}/itsm-ng-${VERSION}.tgz" && \
        tar -xf itsm-ng-${VERSION}.tgz && \
        rm -rf itsm-ng-${VERSION}.tgz && \
        chown -R itsm:itsm /var/www/itsm-ng

COPY files/itsm-ng.conf /etc/apache2/sites-enabled/
COPY files/php-fpm.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY files/apache-phpfpm.conf /etc/apache2/conf-enabled/php8.2-fpm.conf
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD php-fpm8.2 && apachectl -D FOREGROUND
USER itsm
