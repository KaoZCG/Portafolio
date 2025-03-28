FROM composer:2.7 as build
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-pdo_pgsql

FROM php:8.2-apache

# Instalar dependencias
RUN apt-get update && \
    apt-get install -y libpq-dev && \
    docker-php-ext-install pdo pdo_pgsql && \
    a2enmod rewrite

# Configurar Apache para la ruta personalizada
ENV APACHE_DOCUMENT_ROOT /var/www/html/landing-page-portafolio/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copiar la aplicación
COPY --from=build /app /var/www/html/landing-page-portafolio

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/landing-page-portafolio && \
    chmod -R 775 /var/www/html/landing-page-portafolio/storage && \
    chmod -R 775 /var/www/html/landing-page-portafolio/bootstrap/cache