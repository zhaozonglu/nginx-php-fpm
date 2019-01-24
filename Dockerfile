FROM php:7.1-fpm

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        apt-utils \
        git \
        vim \
        curl \
        wget \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
	    libssl-dev \
        libldap2-dev \
        libzip-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
	&& docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install zip \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install opcache \
        && docker-php-ext-install mysqli \
        && docker-php-ext-install sockets \
        && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
        && docker-php-ext-install ldap \
        && docker-php-ext-install pcntl \
        && docker-php-ext-install bcmath \
        && rm -r /var/lib/apt/lists/*

RUN wget http://pecl.php.net/get/redis-4.0.0.tgz -O /home/redis.tgz \
    && wget https://pecl.php.net/get/amqp-1.9.0.tgz -O /home/amqp-1.9.0.tgz \
	&& wget https://github.com/edenhill/librdkafka/archive/v0.11.5.tar.gz -O /home/librdkafka-0.11.5.tar.gz \
	&& wget https://github.com/arnaud-lb/php-rdkafka/archive/3.0.5.tar.gz -O /home/rdkafka-3.0.5.tgz \
    && wget https://github.com/jedisct1/libsodium-php/archive/2.0.20.tar.gz -O /home/libsodium-php.tar.gz \
    && wget https://github.com/jedisct1/libsodium/archive/1.0.16.tar.gz -O /home/libsodium.tar.gz \
    && wget https://github.com/alanxz/rabbitmq-c/archive/v0.8.0.tar.gz -O /home/rabbitmq-c.tar.gz
    

RUN mkdir /home/rdkafka && tar -zxvf /home/rdkafka-3.0.5.tgz -C /home/rdkafka --strip-components 1 \
    && mkdir /home/redis && tar -zxvf /home/redis.tgz -C /home/redis -C /home/redis --strip-components 1 \
    && mkdir /home/librdkafka && tar -zxvf /home/librdkafka-0.11.5.tar.gz -C /home/librdkafka --strip-components 1 \
    && mkdir /home/rabbitmq-c && tar -zxvf /home/rabbitmq-c.tar.gz -C /home/rabbitmq-c --strip-components 1 \
    && mkdir /home/amqp && tar -zxvf /home/amqp-1.9.0.tgz -C /home/amqp --strip-components 1 \
    && mkdir /home/libsodium-php && tar -zxvf /home/libsodium-php.tar.gz -C /home/libsodium-php --strip-components 1 \
    && mkdir /home/libsodium && tar -zxvf /home/libsodium.tar.gz -C /home/libsodium --strip-components 1


RUN cd /home/librdkafka && ./configure && make && make install \
 && cd /home/rdkafka && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/redis && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/rabbitmq-c && ./configure --prefix=/usr/local/rabbitmq-c && make && make install \
 && cd /home/amqp && phpize && ./configure --with-php-config=php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c && make && make install \
 && cd /home/libsodium && ./configure && make && make install \
 && cd /home/libsodium-php && phpize && ./configure --with-php-config=php-config && make && make install 

RUN docker-php-ext-enable redis \
    && docker-php-ext-enable rdkafka \
    && docker-php-ext-enable libsodium \
    && docker-php-ext-enable amqp

# 安装 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN rm -rf /home/*

WORKDIR /data
RUN usermod -u 1000 www-data
