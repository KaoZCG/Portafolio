# Etapa de construcción
FROM composer:2.7 as build

WORKDIR /app
COPY . .

# Ignorar temporalmente la extensión pdo_pgsql durante la instalación de Composer
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-pdo_pgsql

# Etapa de producción
FROM php:8.2-apache

# Instalar dependencias para PostgreSQL
RUN apt-get update && \
    apt-get install -y \
        libpq-dev \
        postgresql-client \
        && \
    docker-php-ext-install \
        pdo \
        pdo_pgsql \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar Apache
RUN a2enmod rewrite
COPY --from=build /app /var/www/html
WORKDIR /var/www/html

# Configurar permisos
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Variables de entorno (se sobrescribirán con las de Render)
ENV APP_ENV=production
ENV APP_DEBUG=false