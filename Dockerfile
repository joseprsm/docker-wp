FROM ubuntu:latest

WORKDIR /usr/src/wordpress

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    curl \
    unzip

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Setup MySQL database, Wordpress
RUN service mysql start \
    && mysql -u root -e "CREATE DATABASE wordpress" \
    && mysql -u root -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password'" \
    && mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost'" \
    && mysql -u root -e "FLUSH PRIVILEGES" \
    && wp core download --allow-root \
    && wp config create --dbname=wordpress --dbpass=password --dbuser=wordpressuser --allow-root \
    && wp core install --url=localhost --title=stswh --admin_user=admin --admin_email=joseprsm@gmail.com --admin_password=admin --allow-root

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite && \
    service apache2 restart

# Install plugins
RUN apt-get update \
  && rm -rf /usr/src/wordpress/wp-content/plugins/* \
  && curl -o /tmp/elementor.zip -SL https://downloads.wordpress.org/plugin/elementor.latest-stable.zip \
  && unzip -q /tmp/elementor.zip -d /usr/src/wordpress/wp-content/plugins/ \
  && rm /tmp/elementor.zip \
  && chown -R www-data:www-data /usr/src/wordpress/wp-content/plugins

EXPOSE 80

CMD service mysql start && wp server --host=0.0.0.0 --allow-root
