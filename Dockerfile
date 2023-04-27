ARG SITE_TITLE
ARG ADMIN_EMAIL
ARG ADMIN_USER="admin"
ARG ADMIN_PASSWORD="admin"

FROM wordpress:latest

WORKDIR /usr/src/wordpress

ENV SITE_TITLE=$SITE_TITLE
ENV ADMIN_USER=$ADMIN_USER
ENV ADMIN_EMAIL=$ADMIN_EMAIL
ENV ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Set the default user to "www-data" to avoid permissions issues
RUN usermod -u 1000 www-data

# Install WordPress
RUN wp core download --allow-root \
    && wp config create --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --dbhost=$WORDPRESS_DB_HOST --allow-root \
    && wp core install --url=localhost --title=$SITE_TITLE --admin_user=$ADMIN_USER --admin_email=$ADMIN_EMAIL --admin_password=$ADMIN_PASSWORD --allow-root

# Install plugins
RUN apt-get update \
  && rm -rf /usr/src/wordpress/wp-content/plugins/* \
  && curl -o /tmp/elementor.zip -SL https://downloads.wordpress.org/plugin/elementor.latest-stable.zip \
  && unzip -q /tmp/elementor.zip -d /usr/src/wordpress/wp-content/plugins/ \
  && rm /tmp/elementor.zip \
  && chown -R www-data:www-data /usr/src/wordpress/wp-content/plugins

EXPOSE 80

ENTRYPOINT [ "wp", "server", "--allow-root" ]
