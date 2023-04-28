FROM ubuntu:latest

WORKDIR /usr/src/wordpress

ARG PLUGINS='["elementor"]'
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    curl \
    unzip \
    jq

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Setup MySQL Database
RUN service mysql start \
    && mysql -u root -e "CREATE DATABASE wordpress" \
    && mysql -u root -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password'" \
    && mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost'" \
    && mysql -u root -e "FLUSH PRIVILEGES" \
    && wp core download --allow-root \
    && wp config create --dbname=wordpress --dbpass=password --dbuser=wordpressuser --allow-root \
    && wp core install --url=localhost --title=stswh --admin_user=admin --admin_email=joseprsm@gmail.com --admin_password=admin --allow-root

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite && \
    service apache2 restart

# Install plugins
RUN service mysql start && wp plugin install $(echo ${PLUGINS} | jq -r ".[]") --activate --allow-root

EXPOSE 80

CMD service mysql start && wp server --host=0.0.0.0 --allow-root
