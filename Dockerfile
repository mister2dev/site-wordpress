# Utiliser une version stable de WordPress avec Apache
FROM wordpress:6.5.3-apache

# Passer root pour installer paquets et modifier Apache
USER root

# 🔧 Corriger les dépôts Debian archivés pour Stretch
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/99ignore-valid && \
    echo "Acquire::AllowInsecureRepositories \"true\";" >> /etc/apt/apt.conf.d/99ignore-valid && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get -o Acquire::AllowInsecureRepositories=true install -y wget unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Installer extensions PHP nécessaires pour PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-enable pgsql pdo_pgsql

# Installer PG4WP (version stable v3.4.1 avec class-wpdb.php)
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget -O pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/tags/v3.4.1.zip && \
    unzip pg4wp.zip && \
    mkdir -p /var/www/html/wp-content/pg4wp && \
    cp -r postgresql-for-wordpress-3.4.1/pg4wp/* /var/www/html/wp-content/pg4wp/ && \
    cp postgresql-for-wordpress-3.4.1/pg4wp/db.php /var/www/html/wp-content/ && \
    cp postgresql-for-wordpress-3.4.1/wp-includes/class-wpdb.php /var/www/html/wp-includes/ && \
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
