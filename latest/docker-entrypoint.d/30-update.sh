#!/bin/sh

# Wait for MySQL to be ready
until nc -z -v -w30 $MARIADB_HOST 3306; do
	echo "Waiting for MySQL connection..."
	sleep 2
done

# Run the update if config_db.php exist
if [ -f /var/www/itsm-ng/config/config_db.php ]; then
	cd /var/www/itsm-ng && php bin/console itsmng:database:update -n
fi
