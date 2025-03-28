# Build stage
FROM composer:2.7 as build

# Instalar Node.js 20 y npm
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-pdo_pgsql
RUN npm install && npm run build

# Production stage
FROM php:8.2-apache

# Install dependencies
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

# Configure Apache (¡ahora apunta directamente a la raíz!)
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