FROM debian:trixie-slim

ARG REPO="itsmng"
ARG VERSION
# Space separated list of itsm-ng plugin names to bake into the image at build time,
# e.g. "accounts barcode formcreator". Runtime plugin installation is not supported
# anymore since it requires root privileges and a writable root filesystem.
ARG ITSMNG_PLUGINS=""

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
        if [ -n "$ITSMNG_PLUGINS" ]; then \
                apt install -y $(for p in $ITSMNG_PLUGINS; do echo "itsm-ng-plugin-$p"; done); \
        fi && \
        ln -s /usr/share/itsm-ng /var/www/itsm-ng && \
        ln -s /etc/itsm-ng /var/www/itsm-ng/config && \
        apt-get -y clean && \
        rm -r /var/lib/apt/lists/* && \
        # Apache/PHP-FPM must be able to run fully as the unprivileged www-data (uid/gid 33)
        # user, so bind on an unprivileged port and pre-create/own every directory that
        # would otherwise need a runtime chown/chmod (forbidden under a restricted
        # PodSecurityStandard with a read-only root filesystem and no CAP_CHOWN).
        sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf && \
        sed -i \
                -e 's#^error_log = .*#error_log = /proc/self/fd/2#' \
                -e 's#^pid = .*#pid = /run/php/php8.4-fpm.pid#' \
                /etc/php/8.4/fpm/php-fpm.conf && \
        sed -i 's#^;\?catch_workers_output = .*#catch_workers_output = yes#' /etc/php/8.4/fpm/pool.d/www.conf && \
        mkdir -p /var/www/itsm-ng/files/_cache \
                /var/www/itsm-ng/files/_cron \
                /var/www/itsm-ng/files/_dumps \
                /var/www/itsm-ng/files/_graphs \
                /var/www/itsm-ng/files/_lock \
                /var/www/itsm-ng/files/_pictures \
                /var/www/itsm-ng/files/_plugins \
                /var/www/itsm-ng/files/_rss \
                /var/www/itsm-ng/files/_sessions \
                /var/www/itsm-ng/files/_tmp \
                /var/www/itsm-ng/files/_uploads \
                /var/run/apache2 /var/lock/apache2 /var/log/apache2 /run/php && \
        chown -R www-data:www-data /usr/share/itsm-ng /etc/itsm-ng \
                /var/run/apache2 /var/lock/apache2 /var/log/apache2 /run/php

COPY --chmod=755 files/itsm-ng.conf /etc/apache2/sites-enabled/
COPY --chmod=755 ./docker-entrypoint.sh /docker-entrypoint.sh
COPY --chmod=755 ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 8080

USER www-data:www-data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sh", "-c", "php-fpm8.4 --nodaemonize --fpm-config /etc/php/8.4/fpm/php-fpm.conf & exec apachectl -D FOREGROUND"]
