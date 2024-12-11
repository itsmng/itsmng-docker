FROM ghcr.io/itsmng/itsm-ng:latest-cron

ARG REPO="itsmng"
ARG VERSION=2.0.2

RUN 	apt update &&\
	apt install wget -y && \
	cd /var/www && \
        wget -q "https://github.com/$REPO/itsm-ng/releases/download/v$VERSION/itsm-ng-v$VERSION.tgz" && \
        tar -xf itsm-ng-v${VERSION}.tgz && \
        rm -rf itsm-ng-v${VERSION}.tgz

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD exit
