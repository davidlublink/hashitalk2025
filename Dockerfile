FROM php:apache

RUN docker-php-ext-install pdo pdo_mysql

COPY index.php /var/www/html/
COPY index.css /var/www/html/