#!/bin/sh

if [ ! -f /var/www/itsm-ng/config/config_db.php ]; then
	sleep 7
	cd /var/www/itsm-ng/files/
	mkdir _cache _cron _dumps _graphs _locales _lock _log _pictures _plugins _rss _sessions _tmp _uploads
	cd /var/www/itsm-ng && php bin/console itsmng:database:install -H $MARIADB_HOST -u $MARIADB_USER -p $MARIADB_PASSWORD -d $MARIADB_DATABASE -n
	chown -R apache:apache /var/www/itsm-ng/files
	rm /var/www/itsm-ng/install/install.php
fi
