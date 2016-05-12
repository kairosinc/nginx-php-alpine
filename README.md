## Introduction
This is a Dockerfile to build a container image for nginx and php-fpmi using Alpine Linux as the base, with the ability to pull website code from git. 

### Git reposiory
The source files for this project can be found here: [https://github.com/kairosinc/nginx-php-alpine](https://github.com/nginx-php-alpine)

If you have any improvements please submit a pull request.

## Running
To simply run the container:

```
sudo docker run --name nginx -p 8080:80 -d registry.prod.kairos.com/nginx-php-alpine
```
You can then browse to http://docker.local:8080 to view the default install files.

### Volumes
If you want to link to your web site directory on the docker host to the container run:

```
sudo docker run --name nginx -p 8080:80 -v /your_code_directory:/usr/share/nginx/html -d richarvey/nginx-php-fpm
```

## Special Features

### Turn on Basic Authentication
To turn on nginx's HTTP basic authentication set an environment variable ENABLE_BASIC_AUTH to true

To create a htpassword file, you can use this:

```
htpasswd -nb YOUR_USERNAME SUPER_SECRET_PASSWORD >/etc/secrets/htpasswd
```

Or to Base64 encode and put inside a volume:

```
htpasswd -nb YOUR_USERNAME SUPER_SECRET_PASSWORD | base64
```

