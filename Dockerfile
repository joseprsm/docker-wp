FROM ubuntu:latest

WORKDIR /usr/src/wordpress

ARG PLUGINS='[]'
ARG SITE_TITLE
ARG ADMIN_EMAIL
ARG ADMIN_USER
ARG ADMIN_PASSWORD

ENV PLUGINS=$PLUGINS
ENV SITE_TITLE=$SITE_TITLE
ENV ADMIN_EMAIL=$ADMIN_EMAIL
ENV ADMIN_USER=$ADMIN_USER
ENV ADMIN_PASSWORD=$ADMIN_PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 80

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

# Run setup
COPY templates templates
COPY plugins plugins
COPY setup .
RUN service mysql start && ./setup

CMD service mysql start && wp server --host=0.0.0.0 --allow-root