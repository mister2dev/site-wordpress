# You can change this to a different version of Wordpress available at
# https://hub.docker.com/_/wordpress
# Utilise une image officielle WordPress avec Apache
FROM wordpress:5.3.2-apache

# Corriger les sources obsolètes de Debian
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip

# Ajouter PG4WP (PostgreSQL for WordPress)
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/old-master.zip && \
    unzip old-master.zip && \
    cp -r postgresql-for-wordpress-hawk-codebase/pg4wp /var/www/html/wp-content/plugins/ && \
    cp postgresql-for-wordpress-hawk-codebase/pg4wp/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

# Assure-toi que les permissions sont correctes
RUN chown -R www-data:www-data /var/www/html/wp-content

# Change le shell de l'utilisateur www-data pour bash (utile pour debug)
RUN usermod -s /bin/bash www-data

# Changer le propriétaire du dossier web
RUN chown www-data:www-data /var/www
USER www-data:www-data
