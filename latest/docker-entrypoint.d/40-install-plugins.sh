#!/bin/sh

until nc -z -v -w30 "$MARIADB_HOST" 3306; do
    echo "Waiting for MySQL connection..."
    sleep 2
done

if [ -n "$ITSMNG_PLUGINS" ]; then
    echo "Installation des plugins ITSM-NG..."

    PACKAGES=""

    for plugin in $ITSMNG_PLUGINS; do
        PACKAGES="$PACKAGES itsm-ng-plugin-$plugin"
    done

    apt-get update
    apt-get install -y $PACKAGES

    rm -rf /var/lib/apt/lists/*
fi