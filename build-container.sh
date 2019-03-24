#!/usr/bin/env bash

set -o errexit

# Create a container
container=$(buildah from fedora:29)

# Labels are part of the "buildah config" command
buildah config --label maintainer="Ken Moini <ken@kenmoini.com>" $container

# Install the needed packages
buildah run $container dnf install -y tar gzip gcc make git bash openssl
buildah run $container dnf install -y nginx
buildah run $container dnf install -y php-fpm php-common
buildah run $container dnf install -y php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongodb php-pecl-redis php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
buildah run $container dnf clean all

# Set Configuration
buildah copy $container nginx.conf /etc/nginx/nginx.conf
buildah copy $container default-site-config.txt /etc/nginx/sites-available/default

# Enable & Start services
buildah run $container systemctl enable nginx
buildah run $container systemctl restart nginx

# Entrypoint, too, is a “buildah config” command
buildah config --entrypoint /var/www $container

# Finally saves the running container to an image
buildah commit --format docker $container nginx-php-fpm:latest
