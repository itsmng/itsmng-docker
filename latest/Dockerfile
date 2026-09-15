# syntax=docker/dockerfile:1.11
#
# Image ITSM-NG.
#
# Principes :
#   - tout est installe et configure au BUILD : aucun apt-get, aucun chown,
#     aucun script de configuration au demarrage du conteneur ;
#   - le conteneur demarre directement Apache (PID 1), sans entrypoint ni
#     supervisor : `docker-entrypoint.d/` n'existe plus ;
#   - la connexion base de donnees est lue dans l'environnement par
#     /etc/itsm-ng/config_db.php : rien n'est ecrit sur le disque au runtime ;
#   - l'image tourne sans privileges (UID non-root, groupe 0) et supporte un
#     UID arbitraire, un rootfs en lecture seule et le profil Pod Security
#     Admission "restricted" de Kubernetes ;
#   - les operations ponctuelles (migration, cron) sont des COMMANDES
#     explicites (`itsmng-init`, `itsmng-cron`, `itsmng-console`), a lancer
#     via un Job / CronJob, pas au boot du serveur web.

ARG DEBIAN_SUITE=trixie
ARG PHP_VERSION=8.4

FROM debian:${DEBIAN_SUITE}-slim AS runtime

ARG DEBIAN_SUITE
ARG PHP_VERSION
# Version applicative, uniquement pour les labels OCI.
ARG VERSION="dev"
# Depot APT ITSM-NG.
ARG ITSMNG_APT_URI="http://deb.itsm-ng.org/debian"
ARG ITSMNG_APT_KEY="http://deb.itsm-ng.org/pubkey.gpg"
# Version exacte du paquet itsm-ng (vide = derniere disponible dans le depot).
ARG ITSMNG_APT_VERSION=""
# Plugins installes DANS l'image, ex: --build-arg ITSMNG_PLUGINS="formcreator pdf".
ARG ITSMNG_PLUGINS=""
# UID applicatif. Le groupe est toujours 0 pour tolerer un UID arbitraire.
ARG UID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    APACHE_RUN_USER=itsmng \
    APACHE_RUN_GROUP=root \
    APACHE_RUN_DIR=/run/apache2 \
    APACHE_LOCK_DIR=/run/apache2 \
    APACHE_PID_FILE=/run/apache2/apache2.pid \
    APACHE_LOG_DIR=/var/log/apache2 \
    ITSMNG_DIR=/usr/share/itsm-ng \
    GLPI_VAR_DIR=/var/lib/itsm-ng

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 1. Depot APT ITSM-NG (cle dans /etc/apt/keyrings + source deb822 signed-by).
# 2. Apache + mod_php + extensions + ITSM-NG + plugins demandes.
# 3. Purge des outils de build : l'image finale n'a plus de quoi installer
#    quoi que ce soit, ce qui est le but.
RUN <<'EOF'
set -euxo pipefail

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gpg

install -d -m 0755 /etc/apt/keyrings
curl -fsSL "${ITSMNG_APT_KEY}" | gpg --dearmor -o /etc/apt/keyrings/itsm-ng.gpg
chmod 0644 /etc/apt/keyrings/itsm-ng.gpg

cat > /etc/apt/sources.list.d/itsm-ng.sources <<SOURCES
Types: deb
URIs: ${ITSMNG_APT_URI}
Suites: ${DEBIAN_SUITE}
Components: main
Signed-By: /etc/apt/keyrings/itsm-ng.gpg
SOURCES

itsmng_pkg="itsm-ng"
if [ -n "${ITSMNG_APT_VERSION}" ]; then
	itsmng_pkg="itsm-ng=${ITSMNG_APT_VERSION}"
fi

plugin_pkgs=()
for plugin in ${ITSMNG_PLUGINS}; do
	plugin_pkgs+=("itsm-ng-plugin-${plugin}")
done

apt-get update
apt-get install -y --no-install-recommends \
	apache2 \
	"libapache2-mod-php${PHP_VERSION}" \
	php-apcu \
	php-cli \
	php-curl \
	php-gd \
	php-intl \
	php-ldap \
	php-mbstring \
	php-mysql \
	php-opcache \
	php-soap \
	php-xml \
	php-xmlrpc \
	php-zip \
	"${itsmng_pkg}" \
	"${plugin_pkgs[@]}"

apt-get purge -y gpg
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

# Apache : mod_php impose mpm_prefork ; on desactive tout ce qui ecrit sur le
# disque ou ouvre le port 80 privilegie.
RUN <<'EOF'
set -euxo pipefail

a2dismod -f mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork "php${PHP_VERSION}" rewrite headers expires
a2disconf "php${PHP_VERSION}-fpm" 2>/dev/null || true
# Ces logs pointent vers ${APACHE_LOG_DIR} : on ne veut que stdout/stderr.
a2disconf other-vhosts-access-log 2>/dev/null || true
rm -f /etc/apache2/sites-enabled/*.conf
EOF

# Arborescence de configuration et scripts : un seul COPY d'un rootfs.
COPY rootfs/ /

RUN <<'EOF'
set -euxo pipefail

a2ensite itsm-ng
a2enconf zz-itsmng

# Le meme fichier ini pour Apache et la CLI (console, cron).
for sapi in apache2 cli; do
	ln -sf /etc/php/conf.d/99-itsmng.ini "/etc/php/${PHP_VERSION}/${sapi}/conf.d/99-itsmng.ini"
done

chmod 0755 /usr/local/bin/itsmng-*

# Compte applicatif : UID fixe, groupe 0. Tous les chemins inscriptibles sont
# donnes au groupe 0 avec les droits du proprietaire, ce qui permet de tourner
# avec un UID arbitraire (PSA restricted, OpenShift) sans aucun chown au boot.
useradd --uid "${UID}" --gid 0 --no-create-home --no-log-init \
	--shell /usr/sbin/nologin itsmng

# Un seul repertoire runtime, sans sous-dossier : un simple tmpfs (ou un
# emptyDir Kubernetes) monte dessus suffit alors a le fournir inscriptible.
install -d -m 0775 -g 0 /run/apache2 "${GLPI_VAR_DIR}"
chgrp -R 0 /run/apache2 "${GLPI_VAR_DIR}" /etc/itsm-ng
chmod -R g=u /run/apache2 "${GLPI_VAR_DIR}" /etc/itsm-ng

# Cablage des chemins attendus par l'application :
#   <app>/config -> /etc/itsm-ng   (GLPI_CONFIG_DIR)
#   /var/www/itsm-ng -> <app>      (compatibilite, chemins historiques)
[ -e "${ITSMNG_DIR}/config" ] || ln -s /etc/itsm-ng "${ITSMNG_DIR}/config"
[ -e /var/www/itsm-ng ] || ln -s "${ITSMNG_DIR}" /var/www/itsm-ng

# Assertions de build : mieux vaut casser ici que servir une instance muette.
test -f "${ITSMNG_DIR}/index.php"
test -f "${ITSMNG_DIR}/bin/console"
test -f "${ITSMNG_DIR}/config/config_db.php"
test -f "${ITSMNG_DIR}/config/local_define.php"
EOF

LABEL org.opencontainers.image.title="ITSM-NG" \
      org.opencontainers.image.description="ITSM-NG, rootless, read-only friendly" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.vendor="ITSM-NG" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/itsmng/itsmng-docker" \
      org.opencontainers.image.documentation="https://wiki.itsm-ng.org"

WORKDIR /usr/share/itsm-ng
USER ${UID}:0
EXPOSE 8080

# Apache s'arrete proprement sur SIGWINCH (graceful-stop) chez Debian.
STOPSIGNAL SIGWINCH

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
	CMD ["curl", "-fsS", "-o", "/dev/null", "http://127.0.0.1:8080/healthz"]

# Pas d'ENTRYPOINT : le conteneur execute directement le serveur, ou l'une des
# commandes explicites itsmng-init / itsmng-cron / itsmng-console.
CMD ["apache2", "-D", "FOREGROUND"]
