#!/bin/sh

if [ ! -d /var/www/itsm-ng/files/_cache ]; then
        mkdir -pv /var/www/itsm-ng/files/{_cache,_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads}
	
	chown -R www-data:www-data /var/www/itsm-ng/files
fi

