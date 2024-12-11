#!/bin/sh

# Wait for MySQL to be ready
until nc -z -v -w30 $MARIADB_HOST 3306; do
        echo "Waiting for MySQL connection..."
        sleep 2
done
