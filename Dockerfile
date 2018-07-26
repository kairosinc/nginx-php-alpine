FROM alpine:3.7
MAINTAINER Cole Calistra <cole@kairos.com>

RUN apk --update add wget \ 
    nginx \
    supervisor \
    bash \
    curl \
    git \
    php7 \
    php7-fpm \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqli \
    php7-mcrypt \
    php7-xml \
    php7-ctype \
    php7-zlib \
    php7-curl \
    php7-openssl \
    php7-iconv \
    php7-json \
    php7-phar \
    php7-dom && \
    rm /var/cache/apk/*            && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /etc/nginx            && \
    mkdir -p /var/www/app          && \
    mkdir -p /run/nginx            && \
    mkdir -p /var/log/supervisor   && \
    rm /etc/nginx/nginx.conf

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php7/php.ini                                           && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 500M/g" /etc/php7/php.ini                          && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 500M/g" /etc/php7/php.ini                                      && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" /etc/php7/php.ini                           && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf                                         && \
    sed -i -e "s/error_log = log\/php7/\/error.log = \/proc\/self\/fd\/2;/g" /etc/php7/php-fpm.d/www.conf              && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php7/php-fpm.d/www.conf            && \
    sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php7/php-fpm.d/www.conf                               && \
    sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php7/php-fpm.d/www.conf                             && \
    sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php7/php-fpm.d/www.conf                     && \
    sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php7/php-fpm.d/www.conf                     && \
    sed -i -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" /etc/php7/php-fpm.d/www.conf                          && \
    sed -i -e "s/user = nobody/user = nginx/g" /etc/php7/php-fpm.d/www.conf                                            && \
    sed -i -e "s/group = nobody/group = nginx/g" /etc/php7/php-fpm.d/www.conf                                          && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php7/php-fpm.d/www.conf                                && \
    sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php7/php-fpm.d/www.conf                           && \
    sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" /etc/php7/php-fpm.d/www.conf                           && \
    sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php7/php-fpm.d/www.conf             && \
    rm -Rf /etc/nginx/conf.d/*                && \
    rm -Rf /etc/nginx/sites-available/default && \
    mkdir -p /etc/nginx/ssl/                  && \
    chmod 755 /start.sh                       && \
    find /etc/php7/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Expose Ports
EXPOSE 443 80

# Start Supervisord
CMD ["/bin/sh", "/start.sh"]
