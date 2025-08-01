# Utiliser une version stable de WordPress avec Apache
FROM wordpress:6.5.3-apache

# Passer root pour installer paquets et modifier Apache
USER root

# Corriger sources Debian archivées + installer wget/unzip
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip && \
    apt-get clean

# Installer extensions PHP nécessaires pour PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
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

# Créer mu-plugins
RUN mkdir -p /var/www/html/wp-content/mu-plugins

# Copier le loader PG4WP mu-plugin
COPY pg4wp-loader.php /var/www/html/wp-content/mu-plugins/pg4wp-loader.php

# Copier wp-config.php personnalisé
COPY wp-config.php /var/www/html/wp-config.php

# Vérifier que WordPress est installé, sinon le copier depuis l'image
RUN if [ ! -f /var/www/html/index.php ]; then \
      echo ">> Installation de WordPress par défaut"; \
      cp -R /usr/src/wordpress/* /var/www/html/; \
      chown -R www-data:www-data /var/www/html; \
    fi


# ✅ Script de démarrage qui adapte Apache au port Render
RUN cat <<'EOF' > /start.sh
#!/bin/bash
set -e
echo ">> Patch Apache avec PORT=$PORT"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/*:80/*:${PORT}/" /etc/apache2/sites-available/000-default.conf
echo ">> Variables d'environnement :"
printenv | grep WORDPRESS_ || true
exec apache2-foreground
EOF

RUN chmod +x /start.sh

# Exposer le port (Render utilisera la variable $PORT)
EXPOSE 10000

# Permissions WordPress
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Rester root pour patcher Apache au runtime
USER root

# Lancer le script
CMD ["/start.sh"]
