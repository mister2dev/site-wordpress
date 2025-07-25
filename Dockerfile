# You can change this to a different version of Wordpress available at
# https://hub.docker.com/_/wordpress
FROM wordpress:5.3.2-apache

RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y magic-wormhole wget unzip

# Ajouter PG4WP (PostgreSQL for WordPress)
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget https://github.com/kevinoid/postgresql-for-wordpress/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cp -r postgresql-for-wordpress-master/pg4wp /var/www/html/wp-content/ && \
    cp postgresql-for-wordpress-master/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

RUN usermod -s /bin/bash www-data
RUN chown www-data:www-data /var/www
USER www-data:www-data
