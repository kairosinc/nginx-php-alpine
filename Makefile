.PHONY: build 

build:
	docker build --no-cache -t quay.io/kairosinc/nginx-php-alpine .
