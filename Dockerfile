FROM php:7.2.8-fpm

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        git \
        vim \
        curl \
        wget \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
	libssl-dev \
        libldap2-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
	&& docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install zip \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install opcache \
        && docker-php-ext-install mysqli \
        && docker-php-ext-install sockets \
        && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
        && docker-php-ext-install ldap \
        && rm -r /var/lib/apt/lists/*

RUN wget http://pecl.php.net/get/redis-4.0.0.tgz -O /home/redis.tgz \
	&& wget https://github.com/edenhill/librdkafka/archive/v0.11.5.tar.gz -O /home/librdkafka-0.11.5.tar.gz \
	&& wget https://github.com/arnaud-lb/php-rdkafka/archive/3.0.5.tar.gz -O /home/rdkafka-3.0.5.tgz \
    && wget https://github.com/swoole/swoole-src/archive/v4.0.4.tar.gz -O /home/swoole.tar.gz \
    && wget https://github.com/mongodb/mongo-php-driver/releases/download/1.5.2/mongodb-1.5.2.tgz -O /home/mongodb.tgz

RUN mkdir /home/rdkafka && tar -zxvf /home/rdkafka-3.0.5.tgz -C /home/rdkafka --strip-components 1 \
    && mkdir /home/librdkafka && tar -zxvf /home/librdkafka-0.11.5.tar.gz -C /home/librdkafka --strip-components 1 \
    && mkdir /home/redis && tar -zxvf /home/redis.tgz -C /home/redis -C /home/redis --strip-components 1 \
    && mkdir /home/swoole && tar -zxvf /home/swoole.tar.gz -C /home/redis -C /home/swoole --strip-components 1 \
    && mkdir /home/mongodb && tar -zxvf /home/mongodb.tgz -C /home/redis -C /home/mongodb --strip-components 1 

 
RUN cd /home/librdkafka && ./configure && make && make install \
 && cd /home/rdkafka && phpize && ./configure && make && make install \
 && cd /home/redis && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/swoole && phpize && ./configure --with-php-config=php-config && make && make install \
 && cd /home/mongodb && phpize && ./configure --with-php-config=php-config && make && make install \

RUN rm -rf /home/*

WORKDIR /data
RUN usermod -u 1000 www-data
