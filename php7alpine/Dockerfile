from alpine

ENV TZ=Asia/Shanghai
RUN addgroup -g 1000 -S www && adduser -u 1000 -S www -s /sbin/nologin -H -G www \
    && apk --no-cache add curl tzdata\
    && apk --no-cache add php7-fpm php7-zip php7-iconv php7-openssl php7-pdo_mysql php7-common php7-mysqli php7-mysqlnd \
       php7-curl php7-json php7-mbstring php7-sockets php7-pdo php7-opcache php7-gd php7-odbc php7-bz2  php7-fileinfo \
       php7-pecl-redis php7-intl php7-pecl-mcrypt php7-gmp php7-dom php7-zlib php7-pecl-memcached php7-pecl-yaml \
       php7-pecl-timezonedb php7-ctype  php7-session php7-phar \
    && curl -sS https://getcomposer.org/installer | php7 -- --install-dir=/usr/bin --filename=composer \
    && mkdir /wwwroot \
    && apk --no-cache del curl

workdir /wwwroot
copy php.ini php-fpm.conf /etc/php7/
expose 9000
cmd [ "php-fpm7", "-F" ]
