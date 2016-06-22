.PHONY: build 

build:
	docker build --no-cache -t kairos/nginx-php-alpine .
