# Etapa de construcción (build)
FROM composer:2.7 as build

WORKDIR /app

# Copiar solo los archivos necesarios para instalar dependencias
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copiar el resto de la aplicación
COPY . .

# Etapa de producción
FROM php:8.2-apache-bullseye

# Instalar extensiones PHP necesarias
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

# Configurar Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copiar la aplicación desde la etapa de construcción
COPY --from=build /app .

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage
RUN chown -R www-data:www-data /var/www/html/bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Variables de entorno (se sobrescribirán con las de Vercel)
ENV APP_ENV production
ENV APP_DEBUG false