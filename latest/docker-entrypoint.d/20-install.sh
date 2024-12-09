#!/bin/sh

# Wait for MySQL to be ready
until nc -z -v -w30 $MARIADB_HOST 3306; do
	echo "Waiting for MySQL connection..."
	sleep 2
done

# Run the installation if config_db.php doesn't exist
if [ ! -f /var/www/itsm-ng/config/config_db.php ]; then
	chmod -R 777 /var/www/itsm-ng/files/_session
	cd /var/www/itsm-ng && php bin/console itsmng:database:install -H $MARIADB_HOST -u $MARIADB_USER -p $MARIADB_PASSWORD -d $MARIADB_DATABASE -n
fi
