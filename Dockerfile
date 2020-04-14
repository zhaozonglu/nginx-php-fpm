FROM php:7.2-fpm

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        apt-utils \
        git \
        vim \
        curl \
        wget \
        procps \
        net-tools \
        iputils-ping \
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

RUN wget http://pecl.php.net/get/redis-4.2.0.tgz -O /home/redis.tgz \
	&& wget https://github.com/edenhill/librdkafka/archive/v0.11.6.tar.gz -O /home/librdkafka-0.11.5.tar.gz \
	&& wget https://github.com/arnaud-lb/php-rdkafka/archive/3.0.5.tar.gz -O /home/rdkafka-3.0.5.tgz \
    && wget https://github.com/swoole/swoole-src/archive/v4.2.12.tar.gz -O /home/swoole.tar.gz \
    && wget https://github.com/laruence/yaf/archive/yaf-3.0.8.tar.gz -O /home/yaf.tar.gz \
    && wget https://github.com/mongodb/mongo-php-driver/releases/download/1.5.2/mongodb-1.5.2.tgz -O /home/mongodb.tgz \
    && wget https://github.com/jedisct1/libsodium-php/archive/1.0.7.tar.gz -O /home/libsodium-php.tar.gz \
    && wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz -O /home/libsodium.tar.gz \
    && wget https://github.com/alanxz/rabbitmq-c/releases/download/v0.8.0/rabbitmq-c-0.8.0.tar.gz -O /home/rabbitmq-c.tar.gz \
    && wget https://pecl.php.net/get/amqp-1.9.4.tgz -O /home/amqp-1.9.4.tgz \
    && wget http://pecl.php.net/get/apcu-5.1.16.tgz -O /home/apcu-5.1.16.tgz

RUN mkdir /home/rdkafka && tar -zxvf /home/rdkafka-3.0.5.tgz -C /home/rdkafka --strip-components 1 \
    && mkdir /home/redis && tar -zxvf /home/redis.tgz -C /home/redis -C /home/redis --strip-components 1 \
    && mkdir /home/swoole && tar -zxvf /home/swoole.tar.gz -C /home/redis -C /home/swoole --strip-components 1 \
    && mkdir /home/mongodb && tar -zxvf /home/mongodb.tgz -C /home/redis -C /home/mongodb --strip-components 1 \
    && mkdir /home/yaf && tar -zxvf /home/yaf.tar.gz -C /home/yaf -C /home/yaf --strip-components 1 \
    && mkdir /home/librdkafka && tar -zxvf /home/librdkafka-0.11.5.tar.gz -C /home/librdkafka --strip-components 1 \
    && mkdir /home/rabbitmq-c && tar -zxvf /home/rabbitmq-c.tar.gz -C /home/rabbitmq-c --strip-components 1 \
    && mkdir /home/amqp && tar -zxvf /home/amqp-1.9.4.tgz -C /home/amqp --strip-components 1 \
    && mkdir /home/libsodium-php && tar -zxvf /home/libsodium-php.tar.gz -C /home/libsodium-php --strip-components 1 \
    && mkdir /home/libsodium && tar -zxvf /home/libsodium.tar.gz -C /home/libsodium --strip-components 1 \
    && mkdir /home/apcu && tar -zxvf /home/apcu-5.1.16.tgz -C /home/apcu --strip-components 1 

RUN cd /home/librdkafka && ./configure && make && make install \
 && cd /home/rdkafka && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/redis && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/swoole && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/mongodb && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/yaf && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/rabbitmq-c && ./configure --prefix=/usr/local/rabbitmq-c && make && make install \
 && cd /home/amqp && phpize && ./configure --with-php-config=php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c && make && make install \
 && cd /home/libsodium && ./configure && make && make install \
 && cd /home/libsodium-php && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/apcu && phpize && ./configure --with-php-config=php-config && make && make install

RUN docker-php-ext-enable redis \
    && docker-php-ext-enable swoole \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable rdkafka \
    && docker-php-ext-enable yaf \
    && docker-php-ext-enable libsodium \
    && docker-php-ext-enable amqp \
    && docker-php-ext-enable apcu

# 安装protobuf扩展
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-php-3.6.1.tar.gz -O /home/protobuf-php-3.6.1.tar.gz \
    && mkdir /home/protobuf-php && tar -zxvf /home/protobuf-php-3.6.1.tar.gz -C /home/protobuf-php --strip-components 1 \
    && cd /home/protobuf-php && ./configure && make && make install \
    && cd /home/protobuf-php/php/ext/google/protobuf && phpize && ./configure --with-php-config=php-config && make && make install \
    && docker-php-ext-enable protobuf \
    && touch /etc/ld.so.conf.d/libprotobuf.conf \
    && echo /usr/local/lib > /etc/ld.so.conf.d/libprotobuf.conf \
    && ldconfig

# 安装 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN rm -rf /home/*

WORKDIR /data
RUN usermod -u 1000 www-data
