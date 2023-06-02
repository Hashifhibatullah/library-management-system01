FROM composer:2.3.5 as build
WORKDIR /app
COPY . /app
RUN composer install && composer dumpautoload
RUN php artisan optimize:clear

FROM php:8.1.0RC5-apache-buster
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libcurl4-gnutls-dev \
    unzip \
    git
RUN docker-php-ext-install pdo pdo_mysql

EXPOSE 80
COPY --from=build /app /var/www/
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod 777 -R /var/www/storage/ && \
  echo "Listen 8080">>/etc/apache2/ports.conf && \
  chown -R www-data:www-data /var/www/ && \
  a2enmod rewrite