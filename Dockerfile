# Utiliser une version récente de WordPress avec Apache
FROM wordpress:6.4-apache

# Passer en root pour installer des paquets
USER root

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    wget unzip libpq-dev \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-enable pgsql pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installer PG4WP
RUN mkdir -p /tmp/pg4wp && \
    cd /tmp/pg4wp && \
    wget -O pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/hawk-codebase.zip && \
    unzip pg4wp.zip && \
    mkdir -p /var/www/html/wp-content/pg4wp && \
    cp -r postgresql-for-wordpress-hawk-codebase/pg4wp/* /var/www/html/wp-content/pg4wp/ && \
    cp postgresql-for-wordpress-hawk-codebase/pg4wp/db.php /var/www/html/wp-content/ && \
    rm -rf /tmp/pg4wp

# Patch pour éviter l'erreur wp_die()
RUN sed -i "s/wp_die( 'PostgreSQL connection failed: '/if ( function_exists('wp_die') ) { wp_die( 'PostgreSQL connection failed: '/" /var/www/html/wp-content/pg4wp/driver_pgsql.php && \
    sed -i "s/pg_last_error() );/pg_last_error() ); } else { die( 'PostgreSQL connection failed: ' . pg_last_error() ); }/" /var/www/html/wp-content/pg4wp/driver_pgsql.php

# Copier le wp-config.php personnalisé
COPY wp-config.php /var/www/html/wp-config.php

# Créer un script de vérification de la connexion DB
RUN echo '#!/bin/bash\n\
until pg_isready -h $WORDPRESS_DB_HOST -p 5432 -U $WORDPRESS_DB_USER; do\n\
  echo "Waiting for PostgreSQL..."\n\
  sleep 2\n\
done\n\
echo "PostgreSQL is ready!"\n\
exec "$@"' > /usr/local/bin/wait-for-postgres.sh && \
    chmod +x /usr/local/bin/wait-for-postgres.sh

# Appliquer les bonnes permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Revenir à l'utilisateur par défaut
USER www-data

# Point d'entrée avec attente de la DB
ENTRYPOINT ["/usr/local/bin/wait-for-postgres.sh"]
CMD ["apache2-foreground"]