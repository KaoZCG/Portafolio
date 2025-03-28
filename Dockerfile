# Etapa de construcción
FROM composer:2.7 as build

WORKDIR /app

# 1. Copiar solo lo necesario para composer
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# 2. Copiar el resto
COPY . .

# Etapa de producción
FROM php:8.2-apache-bullseye

# 1. Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libssl-dev \
        && \
    docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        gd \
        mbstring \
        xml \
        bcmath

# 2. Configurar Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    a2enmod rewrite

# 3. Configurar directorio de trabajo
WORKDIR /var/www/html

# 4. Copiar aplicación
COPY --from=build /app .

# 5. Configurar permisos y directorios necesarios
RUN mkdir -p storage/framework/{cache,sessions,views} && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# 6. Optimizaciones para producción (ejecutar como www-data)
USER www-data
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache