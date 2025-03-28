# Etapa de construcción
FROM composer:2.7 as build
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-pdo_pgsql

# Etapa de producción
FROM php:8.2-apache

# Instalar dependencias y configurar Apache
RUN apt-get update && \
    apt-get install -y \
        libpq-dev \
        git \
        unzip \
        && \
    docker-php-ext-install \
        pdo \
        pdo_pgsql \
        && \
    a2enmod rewrite

# Configurar directorio de documentos de Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/landing-page-portafolio/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copiar la aplicación
COPY --from=build /app /var/www/html/landing-page-portafolio

# Configurar permisos y directorios necesarios
RUN mkdir -p /var/www/html/landing-page-portafolio/storage/framework/{cache,sessions,views} && \
    chown -R www-data:www-data /var/www/html/landing-page-portafolio && \
    chmod -R 775 /var/www/html/landing-page-portafolio/storage /var/www/html/landing-page-portafolio/bootstrap/cache

# Configurar health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1