#!/bin/sh

if [ -f /var/www/itsm-ng/config/config_db.php ]; then
	chown -R www-data:www-data /var/www/itsm-ng/files
fi
