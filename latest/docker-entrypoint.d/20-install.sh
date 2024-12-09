#!/bin/sh

if [ ! -f /var/www/itsm-ng/config/config_db.php ]; then
	sleep 5
	cd /var/www/itsm-ng && php bin/console itsmng:database:install -H $MARIADB_HOST -u $MARIADB_USER -p $MARIADB_PASSWORD -d $MARIADB_DATABASE -n
fi
