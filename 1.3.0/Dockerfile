FROM alpine:3.17

ARG VERSION=1.3.0

RUN apk add --no-cache apache2 bash curl php php-apache2 php-gd php-mbstring php-intl php-opcache php-ldap php-curl php-json php-simplexml php-xml php-mysqli php-fileinfo php-session php-ctype php-iconv php-sodium php-exif php81-pecl-apcu
RUN cd /var/www && \
        wget "https://github.com/itsmng/itsm-ng/releases/download/v${VERSION}/itsm-ng-${VERSION}.tgz" && \
        tar -xf itsm-ng-${VERSION}.tgz && \
        rm -rf itsm-ng-${VERSION}.tgz && \
        chown -R apache:apache /var/www/itsm-ng

COPY files/itsm-ng.conf /etc/apache2/conf.d/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /usr/sbin/httpd -X
