# Build stage
FROM composer:2.7 as build

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-pdo_pgsql

# Production stage
FROM php:8.2-apache

# Install PHP extensions
RUN apt-get update && \
    apt-get install -y \
        libpq-dev \
        libzip-dev \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        && \
    docker-php-ext-install \
        pdo \
        pdo_pgsql \
        zip \
        gd \
        mbstring \
        xml \
        bcmath \
        && \
    a2enmod rewrite

# Configure Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Copy application
COPY --from=build /app /var/www/html

# Permissions
RUN mkdir -p storage/framework/{cache,sessions,views} && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

USER www-data
RUN php artisan migrate --force