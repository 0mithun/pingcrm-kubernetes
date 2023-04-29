FROM php:8.1-fpm as base

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt update && apt install -y zlib1g-dev libpng-dev zip unzip git

RUN docker-php-ext-install exif gd pdo_mysql

FROM base as dev


RUN apt update && apt install -y vim nodejs npm
COPY --from=composer /usr/bin/composer /usr/bin/composer

# COPY . .

# COPY /composer.json composer.json

# RUN composer install

FROM base as build-fpm
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

WORKDIR /var/www/html

# COPY /composer.json composer.json
COPY . .
COPY --chown=www:www . /var/www/html

USER www

RUN composer install -o --no-dev
# RUN ["bash", "-c", "cp .env.example .env"]
RUN php artisan key:generate


FROM build-fpm as test

RUN echo "Test"

FROM build-fpm as fpm 

COPY --from=build-fpm /var/www/html /var/www/html/





FROM node:12 as assets-build
WORKDIR /code

COPY  /package.json /package-lock.json /tailwind.config.js /webpack.config.js /webpack.mix.js /webpack.ssr.mix.js /code/
COPY resources /code/resources/
COPY public /code/public/


RUN npm ci 
RUN npm run prod

FROM nginx as nginx
# COPY --from=assets-build /code/public/css /var/www/html/public/css/
# COPY --from=assets-build /code/public/js /var/www/html/public/js/
# COPY --from=assets-build /code/public/mix-manifest.json /var/www/html/public/
COPY vhost-prod.conf /etc/nginx/conf.d/default.conf 
COPY --from=assets-build /code/public /var/www/html/public/




 