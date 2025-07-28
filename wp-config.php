<?php
// Configuration de la base de données
define('DB_NAME', getenv('WORDPRESS_DB_NAME'));
define('DB_USER', getenv('WORDPRESS_DB_USER'));
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD'));
define('DB_HOST', getenv('WORDPRESS_DB_HOST'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Indique à PG4WP d'utiliser PostgreSQL
define('DB_DRIVER', 'pgsql');

// Préfixe des tables
$table_prefix = 'wp_';

// Clés de sécurité WordPress - GÉNÉREZ DE VRAIES CLÉS !
define('AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'changez-cette-clé-unique');
define('SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'changez-cette-clé-unique');
define('LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'changez-cette-clé-unique');
define('NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'changez-cette-clé-unique');
define('AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'changez-cette-clé-unique');
define('SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'changez-cette-clé-unique');
define('LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'changez-cette-clé-unique');
define('NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'changez-cette-clé-unique');

// Configuration pour Render
define('WP_DEBUG', getenv('WP_DEBUG') === 'true');
define('WP_DEBUG_LOG', WP_DEBUG);
define('WP_DEBUG_DISPLAY', false);

// Forcer HTTPS sur Render
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}

// URL WordPress (important pour Render)
if (isset($_SERVER['HTTP_HOST'])) {
    define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);
    define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST']);
}

// Désactiver l'éditeur de fichiers
define('DISALLOW_FILE_EDIT', true);

// Limiter les révisions
define('WP_POST_REVISIONS', 3);

// Vérifier et charger PG4WP
if (file_exists(__DIR__ . '/wp-content/db.php')) {
    require_once(__DIR__ . '/wp-content/db.php');
} else {
    error_log('Erreur : db.php manquant — PG4WP non installé correctement');
    if (WP_DEBUG) {
        die('Erreur : db.php manquant — PG4WP non installé correctement');
    }
}

// Chemin absolu vers WordPress
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once(ABSPATH . 'wp-settings.php');