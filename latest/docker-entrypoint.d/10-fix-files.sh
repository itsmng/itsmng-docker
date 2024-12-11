#!/bin/sh

if [ ! -d /var/www/itsm-ng/files/_cache ]; then
        mkdir -pv /var/www/itsm-ng/files/_cache 	\
		/var/www/itsm-ng/files/_cron 		\
		/var/www/itsm-ng/files/_dumps 		\
		/var/www/itsm-ng/files/_graphs 		\
		/var/www/itsm-ng/files/_lock 		\
		/var/www/itsm-ng/files/_pictures 	\
		/var/www/itsm-ng/files/_plugins 	\
		/var/www/itsm-ng/files/_rss 		\
		/var/www/itsm-ng/files/_sessions 	\
		/var/www/itsm-ng/files/_tmp 		\
		/var/www/itsm-ng/files/_uploads
	
	chown -R www-data:www-data /var/www/itsm-ng/files
fi

