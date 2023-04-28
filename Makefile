.PHONY: dshell

dshell:
	docker-compose up -d nginx
	docker-compose run --service-ports --rm --entrypoint=bash  php

setup:
	php artisan key:generate
	php artisan migrate
	php artisan db:seed
	npm ci
	npm run dev

dbmig:
	php artisan migrate:fresh
	php artisan db:seed

test:
	php artisan test

build-nginx:
	docker image build -t pingcrm-nginx:latest --target nginx .
#
build-fpm:
	docker image build -t pingcrm-fpm:latest --target fpm .

