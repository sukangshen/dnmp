ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ARG PHP_XDEBUG
ARG PHP_SWOOLE
ARG PHP_REDIS
ARG REPLACE_SOURCE_LIST

COPY ./sources.list /etc/apt/sources.list.tmp
RUN if [ "${REPLACE_SOURCE_LIST}" = "true" ]; then \
    mv /etc/apt/sources.list.tmp /etc/apt/sources.list; else \
    rm -rf /etc/apt/sources.list.tmp; fi
RUN apt update

# Install extensions from source
COPY ./extensions /tmp/extensions
RUN chmod +x /tmp/extensions/install.sh \
    && /tmp/extensions/install.sh \
    && rm -rf /tmp/extensions

# More extensions
# 1. soap requires libxml2-dev.
# 2. xml, xmlrpc, wddx require libxml2-dev and libxslt-dev.
# 3. Line `&& :\` do nothing just for better reading.
## GD

RUN apt update
RUN apt install wget

RUN apt-get update
RUN apt-get install -y wget     #install wget lib
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd

## Intl
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install intl

## General
RUN docker-php-ext-install zip
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mbstring

## SOAP Client
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install soap



RUN apt install librabbitmq-dev -y

RUN wget https://github.com/alanxz/rabbitmq-c/releases/download/v0.8.0/rabbitmq-c-0.8.0.tar.gz -O rabbitmq.tar.gz \
    && mkdir -p rabbitmq \
    && tar -xf rabbitmq.tar.gz -C rabbitmq --strip-components=1 \
    && rm rabbitmq.tar.gz \
    && cd rabbitmq \
    && ./configure --prefix=/usr/local/rabbitmq-dev \
    && make \
    && make install \
    && cd .. \
    && rm -rf rabbitmq


    RUN wget http://pecl.php.net/get/amqp-1.9.3.tgz -O amqp.tar.gz \
        && mkdir -p amqp \
        && tar -xf amqp.tar.gz -C amqp --strip-components=1 \
        && rm amqp.tar.gz \
        && cd amqp \
        && phpize \
        && ./configure --with-php-config=/usr/local/bin/php-config  --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-dev \
        && make -j$(nproc) \
        && make install \
        && docker-php-ext-enable amqp
    RUN docker-php-ext-install sockets

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

COPY ./www /var/www/html
WORKDIR /var/www/html/yii

#RUN composer install --prefer-source --no-interaction

#ENV PATH="~/.composer/vendor/bin:./vendor/bin:${PATH}"

RUN usermod -u 1000 www-data

#    && docker-php-ext-install $mc bcmath \
#    && docker-php-ext-install $mc calendar \
#    && docker-php-ext-install $mc sockets \
#    && docker-php-ext-install $mc gettext \
#    && docker-php-ext-install $mc shmop \
#    && docker-php-ext-install $mc sysvmsg \
#    && docker-php-ext-install $mc sysvsem \
#    && docker-php-ext-install $mc sysvshm \
#    && docker-php-ext-install $mc pdo_firebird \
#    && docker-php-ext-install $mc pdo_dblib \
#    && docker-php-ext-install $mc pdo_oci \
#    && docker-php-ext-install $mc pdo_odbc \
#    && docker-php-ext-install $mc pdo_pgsql \
#    && docker-php-ext-install $mc pgsql \
#    && docker-php-ext-install $mc oci8 \
#    && docker-php-ext-install $mc odbc \
#    && docker-php-ext-install $mc dba \
#    && docker-php-ext-install $mc interbase \
#    && :\
#    && apt install -y libxml2-dev \
#    && apt install -y libxslt-dev \
#    && docker-php-ext-install $mc soap \
#    && docker-php-ext-install $mc xsl \
#    && docker-php-ext-install $mc xmlrpc \
#    && docker-php-ext-install $mc wddx \
#    && :\
#    && apt install -y unixodbc-dev \
#    && pecl install sqlsrv pdo_sqlsrv \
#    && docker-php-ext-enable sqlsrv pdo_sqlsrv
#    && :\
#    && apt install -y curl \
#    && apt install -y libcurl3 \
#    && apt install -y libcurl4-openssl-dev \
#    && docker-php-ext-install $mc curl \
#    && :\
#    && apt install -y libreadline-dev \
#    && docker-php-ext-install $mc readline \
#    && :\
#    && apt install -y libsnmp-dev \
#    && apt install -y snmp \
#    && docker-php-ext-install $mc snmp \
#    && :\
#    && apt install -y libpspell-dev \
#    && apt install -y aspell-en \
#    && docker-php-ext-install $mc pspell \
#    && :\
#    && apt install -y librecode0 \
#    && apt install -y librecode-dev \
#    && docker-php-ext-install $mc recode \
#    && :\
#    && apt install -y libtidy-dev \
#    && docker-php-ext-install $mc tidy \
#    && :\
#    && apt install -y libgmp-dev \
#    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
#    && docker-php-ext-install $mc gmp \
#    && :\
#    && apt install -y postgresql-client \
#    && apt install -y mysql-client \
#    && :\
#    && apt install -y libc-client-dev \
#    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
#    && docker-php-ext-install $mc imap \
#    && :\
#    && apt install -y libldb-dev \
#    && apt install -y libldap2-dev \
#    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
#    && docker-php-ext-install $mc ldap \
#    && :\
#    && apt install -y libmagickwand-dev \
#    && pecl install imagick-3.4.3 \
#    && docker-php-ext-enable imagick \
#    && :\
#    && apt install -y libmemcached-dev zlib1g-dev \
#    && pecl install memcached-2.2.0 \
#    && docker-php-ext-enable memcached
