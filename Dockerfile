# Utiliser une version stable de WordPress avec Apache
FROM wordpress:6.8.2-apache

# Passer root pour installer paquets et modifier Apache
USER root

RUN apt-get update && \
    apt-get install -y wget unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Vérifier que WordPress est installé, sinon le copier depuis l'image
RUN if [ ! -f /var/www/html/index.php ]; then \
      cp -R /usr/src/wordpress/* /var/www/html/; \
      chown -R www-data:www-data /var/www/html; \
    fi

# Installer extensions PHP nécessaires pour PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-enable pgsql pdo_pgsql

# Installer WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Installer PG4WP
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

# Installer Elementor + Cloudinary + Thème Astra
# Créer le dossier plugins et themes
RUN mkdir -p /var/www/html/wp-content/plugins && \
    mkdir -p /var/www/html/wp-content/themes

# Elementor
RUN curl -L https://downloads.wordpress.org/plugin/elementor.latest-stable.zip -o /tmp/elementor.zip && \
    unzip /tmp/elementor.zip -d /var/www/html/wp-content/plugins/ && \
    rm /tmp/elementor.zip

# Cloudinary
RUN curl -L https://downloads.wordpress.org/plugin/cloudinary-image-management-and-manipulation-in-the-cloud-cdn.latest-stable.zip -o /tmp/cloudinary.zip && \
    unzip /tmp/cloudinary.zip -d /var/www/html/wp-content/plugins/ && \
    rm /tmp/cloudinary.zip

# Astra Theme
RUN curl -L https://downloads.wordpress.org/theme/astra.latest-stable.zip -o /tmp/astra.zip && \
    unzip /tmp/astra.zip -d /var/www/html/wp-content/themes/ && \
    rm /tmp/astra.zip

# Installer Code Snippets plugin
RUN curl -L https://downloads.wordpress.org/plugin/code-snippets.latest-stable.zip -o /tmp/code-snippets.zip && \
    unzip /tmp/code-snippets.zip -d /var/www/html/wp-content/plugins/ && \
    rm /tmp/code-snippets.zip

# **Création du dossier uploads et copie des images**
RUN mkdir -p /var/www/html/wp-content/uploads/2025/08
COPY img/*.webp /var/www/html/wp-content/uploads/2025/08/

# Copie des CSS capturés (Elementor, plugins…)
COPY wp-content /var/www/html/wp-content

# Permissions sur les images copiées
RUN chown -R www-data:www-data /var/www/html/wp-content/uploads/2025 && \
    chmod -R 755 /var/www/html/wp-content/uploads/2025

# Importer les images dans la médiathèque WordPress
RUN wp media import /var/www/html/wp-content/uploads/2025/08/*.jpg \
    --allow-root \
    --path=/var/www/html \
    --featured_image

# Copier le .htaccess prêt
COPY .htaccess /var/www/html/.htaccess
RUN chown www-data:www-data /var/www/html/.htaccess

# Script de démarrage Render
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

# Permissions WordPress
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Lancer le script
CMD ["/start.sh"]