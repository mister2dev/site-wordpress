<?php
// Debug : afficher toutes les variables WP dans les logs PHP
$env_vars = [
    'WORDPRESS_DB_NAME',
    'WORDPRESS_DB_USER',
    'WORDPRESS_DB_PASSWORD',
    'WORDPRESS_DB_HOST',
    'WORDPRESS_AUTH_KEY',
    'WORDPRESS_SECURE_AUTH_KEY',
    'WORDPRESS_LOGGED_IN_KEY',
    'WORDPRESS_NONCE_KEY',
    'WORDPRESS_AUTH_SALT',
    'WORDPRESS_SECURE_AUTH_SALT',
    'WORDPRESS_LOGGED_IN_SALT',
    'WORDPRESS_NONCE_SALT',
];

foreach ($env_vars as $var) {
    error_log("$var=" . getenv($var));
}

// Spécifique : afficher aussi ce que WordPress a défini
error_log('DB_NAME=' . (defined('DB_NAME') ? DB_NAME : 'non défini'));
error_log('DB_USER=' . (defined('DB_USER') ? DB_USER : 'non défini'));
error_log('DB_PASSWORD=' . (defined('DB_PASSWORD') ? DB_PASSWORD : 'non défini'));
error_log('DB_HOST=' . (defined('DB_HOST') ? DB_HOST : 'non défini'));




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

// 12. Définir ABSPATH si ce n'est pas déjà fait
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// 13. Charger le reste de WordPress
require_once(ABSPATH . 'wp-settings.php');
