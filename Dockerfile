# You can change this to a different version of Wordpress available at
# https://hub.docker.com/_/wordpress
# Utilise une version stable de WordPress avec Apache
FROM wordpress:5.3.2-apache

# Basculer en root pour les installations
USER root

# Correction des sources Debian archivées + installation d'utilitaires
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip && \
    apt-get clean

# Installer le patch PostgreSQL (PG4WP)
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget -O pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/hawk-codebase.zip && \
    unzip pg4wp.zip && \
    cp -r postgresql-for-wordpress-hawk-codebase/pg4wp /var/www/html/wp-content/ && \
    cp postgresql-for-wordpress-hawk-codebase/pg4wp/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

# Appliquer les permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Revenir à www-data pour exécuter Apache
USER www-data
