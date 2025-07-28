<?php
define('DB_NAME', getenv('WORDPRESS_DB_NAME'));
define('DB_USER', getenv('WORDPRESS_DB_USER'));
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD'));
define('DB_HOST', getenv('WORDPRESS_DB_HOST'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('DB_DRIVER', 'pgsql');  // Indique PG4WP d'utiliser PostgreSQL

$table_prefix = 'wp_';

// Clés de sécurité
define('AUTH_KEY',         'change‑this');
define('SECURE_AUTH_KEY',  'change‑this');
define('LOGGED_IN_KEY',    'change‑this');
define('NONCE_KEY',        'change‑this');
define('AUTH_SALT',        'change‑this');
define('SECURE_AUTH_SALT', 'change‑this');
define('LOGGED_IN_SALT',   'change‑this');
define('NONCE_SALT',       'change‑this');

define('WP_DEBUG', false);

// if (file_exists(__DIR__ . '/wp-content/db.php')) {
//     require_once(__DIR__ . '/wp-content/db.php');
// } else {
//     die('Erreur : db.php manquant — PG4WP non installé correctement');
// }

if (!defined('ABSPATH'))
    define('ABSPATH', __DIR__ . '/');

require_once(ABSPATH . 'wp-settings.php');
