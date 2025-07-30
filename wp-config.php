<?php
// 1. Définitions des constantes de connexion à la base de données,
// issues des variables d'environnement (Render injecte ces variables)
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: '');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: '');
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: '');
define('DB_HOST', getenv('WORDPRESS_DB_HOST') ?: '');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// 2. Indiquer à PG4WP d'utiliser PostgreSQL
define('DB_DRIVER', 'pgsql');

// 3. Clé pour autoriser la connexion sans mot de passe (optionnel,
// seulement si tu veux éviter l’erreur d’avertissement)
define('PG4WP_INSECURE', true);

// 4. Préfixe des tables
$table_prefix = 'wp_';

// 5. Clés et sels de sécurité (tu peux générer ici des vrais via https://api.wordpress.org/secret-key/1.1/salt/)
define('AUTH_KEY',         getenv('WORDPRESS_AUTH_KEY') ?: 'changez-cette-clé-unique');
define('SECURE_AUTH_KEY',  getenv('WORDPRESS_SECURE_AUTH_KEY') ?: 'changez-cette-clé-unique');
define('LOGGED_IN_KEY',    getenv('WORDPRESS_LOGGED_IN_KEY') ?: 'changez-cette-clé-unique');
define('NONCE_KEY',        getenv('WORDPRESS_NONCE_KEY') ?: 'changez-cette-clé-unique');
define('AUTH_SALT',        getenv('WORDPRESS_AUTH_SALT') ?: 'changez-cette-clé-unique');
define('SECURE_AUTH_SALT', getenv('WORDPRESS_SECURE_AUTH_SALT') ?: 'changez-cette-clé-unique');
define('LOGGED_IN_SALT',   getenv('WORDPRESS_LOGGED_IN_SALT') ?: 'changez-cette-clé-unique');
define('NONCE_SALT',       getenv('WORDPRESS_NONCE_SALT') ?: 'changez-cette-clé-unique');

// 6. Debug et logs (optionnel)
define('WP_DEBUG', getenv('WP_DEBUG') === 'true');
define('WP_DEBUG_LOG', WP_DEBUG);
define('WP_DEBUG_DISPLAY', false);

// 7. Forcer HTTPS si nécessaire (Render utilise des proxys)
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}

// 8. URL du site WordPress (important sur Render)
if (isset($_SERVER['HTTP_HOST'])) {
    define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);
    define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST']);
}

// 9. Désactiver l'éditeur de fichiers WordPress (sécurité)
define('DISALLOW_FILE_EDIT', true);

// 10. Limiter le nombre de révisions
define('WP_POST_REVISIONS', 3);

// 11. Charger PG4WP (le driver PostgreSQL)
if (file_exists(__DIR__ . '/wp-content/db.php')) {
    require_once(__DIR__ . '/wp-content/db.php');
} else {
    error_log('Erreur : PG4WP db.php manquant');
    if (WP_DEBUG) {
        die('Erreur : PG4WP db.php manquant — installation incorrecte');
    }
}

// 12. Définir ABSPATH si ce n'est pas déjà fait
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// 13. Charger le reste de WordPress
require_once(ABSPATH . 'wp-settings.php');
