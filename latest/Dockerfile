FROM debian:trixie-slim

ARG REPO="itsmng"
ARG VERSION

RUN apt update && apt dist-upgrade -y && \
        apt install -y apache2 wget php php-fpm php-mysql php-intl php-mbstring php-gd php-ldap php-simplexml php-curl php-apcu php-xmlrpc php-soap netcat-traditional && \
        apt install -y curl gpg && \
        a2enmod proxy_fcgi setenvif && \
        a2enconf php8.4-fpm && \
        rm /etc/apache2/sites-enabled/000-default.conf && \
	echo "apc.enable_cli=1" >> /etc/php/8.4/cli/conf.d/20-apcu.ini && \
        curl -fsSL http://deb.itsm-ng.org/pubkey.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/itsm-ng-keyring.gpg && \
        echo "deb http://deb.itsm-ng.org/debian trixie main" | tee /etc/apt/sources.list.d/itsm-ng.list && \
        apt update && \
        apt install -y itsm-ng && \
        ln -s /usr/share/itsm-ng /var/www/itsm-ng && \
        ln -s /etc/itsm-ng /var/www/itsm-ng/config && \
        apt-get -y clean && \
        rm -r /var/lib/apt/lists/*

COPY files/itsm-ng.conf /etc/apache2/sites-enabled/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /etc/init.d/php8.4-fpm start && apachectl -D FOREGROUND
