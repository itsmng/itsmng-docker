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

if [ -f /etc/itsm-ng/local_define.php ]; then
    cat > /var/www/itsm-ng/config/local_define.php <<'EOF'
<?php
define('GLPI_VAR_DIR', '/var/lib/itsm-ng');
define('GLPI_DOC_DIR', GLPI_VAR_DIR);
EOF
fi