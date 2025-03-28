FROM composer:2.7 as build
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

FROM php:8.2-apache
RUN docker-php-ext-install pdo pdo_pgsql
WORKDIR /var/www/html
COPY --from=build /app .
RUN chmod -R 775 storage bootstrap/cache