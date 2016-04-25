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
### Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

**Note:** You need to have your SSH key that you use with git to enable the deployment. I recommend using a special deploy key per project to minimise the risk.

To run the container and pull code simply specify the GIT_REPO URL including *git@* and then make sure you have a folder on the docker host with your id_rsa key stored in it:

```
sudo docker run -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git'  -v /opt/ngddeploy/:/root/.ssh -p 8080:80 -d richarvey/nginx-php-fpm
```

To pull a repository and specify a branch add the GIT_BRANCH environment variable:

```
sudo docker run -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'GIT_BRANCH=stage' -v /opt/ngddeploy/:/root/.ssh -p 8080:80 -d richarvey/nginx-php-fpm
```
### Linking
Linking to containers also exposes the linked container environment variables which is useful for templating and configuring web apps.

Run MySQL container with some extra details:

```
sudo docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=yayMySQL -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress_user -e MYSQL_PASSWORD=wordpress_password -d mysql
```

This exposes the following environment variables to the container when linked:

```
MYSQL_ENV_MYSQL_DATABASE=wordpress
MYSQL_ENV_MYSQL_ROOT_PASSWORD=yayMySQL
MYSQL_PORT_3306_TCP_PORT=3306
MYSQL_PORT_3306_TCP=tcp://172.17.0.236:3306
MYSQL_ENV_MYSQL_USER=wordpress_user
MYSQL_ENV_MYSQL_PASSWORD=wordpress_password
MYSQL_ENV_MYSQL_VERSION=5.6.22
MYSQL_NAME=/sick_mccarthy/mysql
MYSQL_PORT_3306_TCP_PROTO=tcp
MYSQL_PORT_3306_TCP_ADDR=172.17.0.236
MYSQL_ENV_MYSQL_MAJOR=5.6
MYSQL_PORT=tcp://172.17.0.236:3306

```

To link the container launch like this:

```
sudo docker run -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -v /opt/ngddeploy/:/root/.ssh -p 8080:80 --link some-mysql:mysql -d richarvey/nginx-php-fpm
```
### Enabling SSL or Special Nginx Configs
As with all docker containers its possible to link resources from the host OS to the guest. This makes it really easy to link in custom nginx default config files or extra virtual hosts and SSL enabled sites. For SSL sites first create a directory somewhere such as */opt/deployname/ssl/*. In this directory drop you SSL cert and Key in. Next create a directory for your custom hosts such as  */opt/deployname/sites-enabled*. In here load your custom default.conf file which references your SSL cert and keys at the location, for example:  */etc/nginx/ssl/xxxx.key*

Then start your container and connect these volumes like so:

```
sudo docker run -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -v /opt/ngddeploy/:/root/.ssh -v /opt/deployname/ssl:/etc/nginx/ssl -v /opt/deployname/sites-enabled:/etc/nginx/sites-enabled -p 8080:80 --link some-mysql:mysql -d richarvey/nginx-php-fpm
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

### Push code to Git
To push code changes back to git simply run:
```
sudo docker exec -t -i <CONATINER_NAME> /usr/bin/push
```
### Pull code from Git (Refresh)
In order to refresh the code in a container and pull newer code form git simply run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```

