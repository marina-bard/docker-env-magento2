FROM alpine:3.7

RUN apk update && \
    apk add bash \
        openrc \
        nano \
        grep

# Install nginx
RUN apk add nginx
ADD ./conf/nginx.conf /etc/nginx
ADD ./conf/magento2.conf /etc/nginx/conf.d/magento2.conf
ADD ./conf/upstream.conf /etc/nginx/conf.d/upstream.conf
RUN rm /etc/nginx/conf.d/default.conf
RUN mkdir -p /run/nginx

#Install mysql
RUN apk add mysql mysql-client
RUN mkdir -p /run/mysqld

# Install php-fpm
RUN apk add php7 \
        php7-fpm \
        php7-opcache \
        php7-json \
        php7-phar \
        php7-iconv \
        php7-openssl \
        php7-pdo \
        php7-mysqli \
        php7-pdo_mysql \
        php7-simplexml \
        php7-ctype \
        php7-dom \
        php7-gd \
        php7-tokenizer \
        php7-mbstring \
        php7-xml \
        php7-mcrypt \
        php7-xmlwriter \
        php7-bcmath \
        php7-curl \
        php7-intl \
        php7-xsl \
        php7-zip \
        php7-soap \
        php7-session \
        php7-sockets

COPY ./conf/php.ini /etc/php7/conf.d/50-setting.ini
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install Composer
RUN apk add curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer --version
ADD ./conf/auth.json /root/.composer/auth.json

WORKDIR /var/www/magento2

EXPOSE 80

ADD ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]


