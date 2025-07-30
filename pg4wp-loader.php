<?php
// Chargement automatique de PG4WP si présent
if (file_exists(WP_CONTENT_DIR . '/db.php')) {
    require_once WP_CONTENT_DIR . '/db.php';
}
