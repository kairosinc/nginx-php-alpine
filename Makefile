.PHONY: build 

build:
	docker build --no-cache -t registry.prod.kairos.com/nginx-php-alpine .
