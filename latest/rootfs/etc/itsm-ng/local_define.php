<?php
/**
 * Emplacement des donnees variables, fige au build de l'image.
 *
 * Tout ce que l'application ecrit (cache, sessions, documents, dumps, logs)
 * vit sous GLPI_VAR_DIR, qui est le SEUL volume inscriptible necessaire.
 * Le reste de l'image peut rester en lecture seule.
 */

define('GLPI_VAR_DIR', '/var/lib/itsm-ng');
define('GLPI_DOC_DIR', GLPI_VAR_DIR);
