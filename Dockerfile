# Utiliser WordPress avec Apache
FROM wordpress:5.3.2-apache

# Passer root pour installer paquets et modifier Apache
USER root

# Installer extensions PHP nécessaires pour PostgreSQL et wget/unzip
RUN apt-get update && apt-get install -y wget unzip libpq-dev \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-enable pgsql pdo_pgsql

# Installer PG4WP
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget -O pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/hawk-codebase.zip && \
    unzip pg4wp.zip && \
    mkdir -p /var/www/html/wp-content/pg4wp && \
    cp -r postgresql-for-wordpress-hawk-codebase/pg4wp/* /var/www/html/wp-content/pg4wp/ && \
    cp postgresql-for-wordpress-hawk-codebase/pg4wp/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

# Créer dossier mu-plugins pour le loader PG4WP
RUN mkdir -p /var/www/html/wp-content/mu-plugins

# Copier fichiers custom
COPY pg4wp-loader.php /var/www/html/wp-content/mu-plugins/pg4wp-loader.php
COPY wp-config.php /var/www/html/wp-config.php

# Permissions WordPress
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# ✅ Script de démarrage qui adapte Apache au port Render
RUN echo '#!/bin/bash
set -e
echo ">> Patch Apache avec PORT=$PORT"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/*:80/*:${PORT}/" /etc/apache2/sites-available/000-default.conf
echo ">> Variables d'environnement :"
printenv | grep WORDPRESS_ || true
exec apache2-foreground
' > /start.sh && chmod +x /start.sh

# Rester root pour pouvoir patcher Apache au runtime
USER root

# Lancer le script
CMD ["/start.sh"]
