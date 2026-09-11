#!/bin/sh

# Directories are already created and owned by www-data at image build time
# (see Dockerfile); this only covers the case of a fresh, empty bind mount.
mkdir -pv /var/www/itsm-ng/files/_cache \
		/var/www/itsm-ng/files/_cron \
		/var/www/itsm-ng/files/_dumps \
		/var/www/itsm-ng/files/_graphs \
		/var/www/itsm-ng/files/_lock \
		/var/www/itsm-ng/files/_pictures \
		/var/www/itsm-ng/files/_plugins \
		/var/www/itsm-ng/files/_rss \
		/var/www/itsm-ng/files/_sessions \
		/var/www/itsm-ng/files/_tmp \
		/var/www/itsm-ng/files/_uploads

if [ -f /etc/itsm-ng/local_define.php ]; then
    cat > /var/www/itsm-ng/config/local_define.php <<'EOF'
<?php
define('GLPI_VAR_DIR', '/var/lib/itsm-ng');
define('GLPI_DOC_DIR', GLPI_VAR_DIR);
EOF
fi