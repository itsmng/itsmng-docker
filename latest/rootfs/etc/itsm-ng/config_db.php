<?php
/**
 * Connexion base de donnees pilotee par l'environnement.
 *
 * Ce fichier est livre dans l'image et n'est JAMAIS reecrit au demarrage :
 * c'est ce qui permet de garder un rootfs en lecture seule et de ne
 * persister aucune configuration dans un volume.
 *
 * Variables reconnues :
 *   MARIADB_HOST      hote de la base                       (defaut: localhost)
 *   MARIADB_PORT      port                                  (defaut: celui du client)
 *   MARIADB_USER      utilisateur                           (defaut: itsmng)
 *   MARIADB_PASSWORD  mot de passe
 *   MARIADB_DATABASE  nom de la base                        (defaut: itsmng)
 *   MARIADB_SSL_CA / _CERT / _KEY   TLS vers la base        (optionnel)
 *
 * Chaque variable accepte un suffixe _FILE pointant vers un fichier : c'est
 * la forme a utiliser pour un Secret Kubernetes ou un secret Docker, afin de
 * ne pas exposer le mot de passe dans l'environnement du processus.
 *
 * Pour reprendre la main completement, monter son propre fichier par-dessus
 * /etc/itsm-ng/config_db.php.
 */

if (!function_exists('itsmng_env')) {
    function itsmng_env(string $name, ?string $default = null): ?string
    {
        $file = getenv($name . '_FILE');
        if (is_string($file) && $file !== '') {
            $value = @file_get_contents($file);
            if ($value === false) {
                throw new RuntimeException(
                    sprintf('ITSM-NG: impossible de lire %s_FILE (%s)', $name, $file)
                );
            }
            // Un secret monte en fichier se termine souvent par un retour ligne.
            return rtrim($value, "\r\n");
        }

        $value = getenv($name);

        return (is_string($value) && $value !== '') ? $value : $default;
    }
}

class DB extends DBmysql
{
    public function __construct()
    {
        $host = itsmng_env('MARIADB_HOST', 'localhost');
        $port = itsmng_env('MARIADB_PORT');
        if ($port !== null) {
            $host .= ':' . $port;
        }

        $this->dbhost    = $host;
        $this->dbuser    = itsmng_env('MARIADB_USER', 'itsmng');
        $this->dbdefault = itsmng_env('MARIADB_DATABASE', 'itsmng');

        // L'application applique rawurldecode() au mot de passe stocke ici
        // (comportement historique de l'installeur). On encode donc pour que
        // les caracteres speciaux d'un mot de passe genere passent intacts.
        $password = itsmng_env('MARIADB_PASSWORD', '');
        $encode   = filter_var(
            itsmng_env('ITSMNG_DB_PASSWORD_RAWURLENCODE', 'true'),
            FILTER_VALIDATE_BOOLEAN
        );
        $this->dbpassword = $encode ? rawurlencode($password) : $password;

        $sslCa   = itsmng_env('MARIADB_SSL_CA');
        $sslCert = itsmng_env('MARIADB_SSL_CERT');
        $sslKey  = itsmng_env('MARIADB_SSL_KEY');
        if ($sslCa !== null || $sslCert !== null || $sslKey !== null) {
            $this->dbssl     = true;
            $this->dbsslca   = $sslCa;
            $this->dbsslcert = $sslCert;
            $this->dbsslkey  = $sslKey;
        }

        parent::__construct();
    }
}
