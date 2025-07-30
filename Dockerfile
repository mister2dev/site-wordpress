# Utiliser une version stable de WordPress avec Apache
FROM wordpress:5.3.2-apache

# Passer en root pour installer des paquets
USER root

# Corriger les sources Debian archivées + installer wget/unzip
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip && \
    apt-get clean

# Installer les extensions PHP nécessaires pour PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-enable pgsql pdo_pgsql

# Installer PG4WP dans le bon dossier
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget -O pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/hawk-codebase.zip && \
    unzip pg4wp.zip && \
    mkdir -p /var/www/html/wp-content/pg4wp && \
    cp -r postgresql-for-wordpress-hawk-codebase/pg4wp/* /var/www/html/wp-content/pg4wp/ && \
    cp postgresql-for-wordpress-hawk-codebase/pg4wp/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

# Créer le dossier mu-plugins s’il n’existe pas
RUN mkdir -p /var/www/html/wp-content/mu-plugins

# Copier le loader PG4WP mu-plugin
COPY pg4wp-loader.php /var/www/html/wp-content/mu-plugins/pg4wp-loader.php


# Copier ton wp-config.php personnalisé
COPY wp-config.php /var/www/html/wp-config.php

# Forcer Apache à écouter sur le port que Render fournit
ENV APACHE_RUN_PORT=${PORT}

# Indiquer à Apache d'écouter sur $PORT fourni par Render
ENV PORT=10000
RUN sed -i "s/80/\${PORT}/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
EXPOSE 10000


# Appliquer les bonnes permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Revenir à l'utilisateur par défaut d'Apache
USER www-data
