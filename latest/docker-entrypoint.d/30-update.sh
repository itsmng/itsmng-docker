#!/bin/sh

if [ -f /var/www/itsm-ng/config/config_db.php ]; then
	sleep 5
	cd /var/www/itsm-ng && php bin/console itsmng:database:update -n
fi
