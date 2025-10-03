FROM ghcr.io/aphp/redcap-php-fpm:1.2.0

USER root
RUN apt-get update && apt-get install -y \
    vim \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libicu-dev \
    libxslt1-dev \
    libldap2-dev \
    libc-client-dev \
    libkrb5-dev \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) \
       ldap \
       bcmath \
       calendar \
       exif \
       ftp \
       gettext \
       pcntl \
       shmop \
       sockets \
       sysvmsg \
       sysvsem \
       sysvshm \
       xsl \
       opcache \
       ffi \
    && rm -rf /var/lib/apt/lists/*

