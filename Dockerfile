FROM php:7.2-apache
LABEL Name=PHP-7.2 Version=1.0

# Expoe a porta 80
EXPOSE 80

# Copia a configuração do PHP para a pasta do apache
COPY ./php.ini ${PHP_INI_DIR}/php.ini

# Como sei que o laravel é dentro da pasta public, altero o document root pra lá
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilita o Mod Rewrite do Apache 2
RUN a2enmod rewrite

# Instala o composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Instala o GIT
RUN apt-get update && apt-get -y install git

# Instala as extensoes do php
RUN apt-get update && \
    apt-get -y install apt-utils curl && \ 
    # Instala o driver do SQL Server
    apt-get -y install freetds-common libsybdb5 && \
    # Instala bibliotecas para xml e zip
    apt-get -y install libxml2-dev libzip-dev

# Instala os headers de drivers odbc 
RUN apt-get -y install unixodbc-dev

# Instala bibliotecas SSL para o MONGO DB
#RUN apt-get -y install libcurl4-openssl-dev 
RUN apt-get -y install pkg-config 
RUN apt-get -y install libssl-dev 

# Instala o driver do Mongo DB
RUN pecl install mongodb
# Instala o driver do sql server para o PHP
RUN pecl install pdo_sqlsrv

# Instala outras extensoes uteis
RUN docker-php-ext-install exif bcmath xmlrpc mbstring zip
# Habilita no PHP.ini as extensoes do mongo e sql server
RUN docker-php-ext-enable mongodb
RUN docker-php-ext-enable pdo_sqlsrv


# Instala o driver ODBC do sql server
RUN apt-get -y install gnupg
RUN apt-get install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y --allow-unauthenticated install msodbcsql17

# Instala a biblioteca GD
RUN apt-get update -y && apt-get install -y libpng-dev
RUN docker-php-ext-install gd

# Instala as extensões do mysql e mysqli
RUN docker-php-ext-install pdo_mysql mysqli

# Habilita o Mod Rewrite do Apache 2
RUN a2enmod rewrite

# Habilita o SSL do Apache 2
RUN a2enmod ssl

RUN yes | pecl install xdebug-2.7.2 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Instala o GhostScript
RUN apt-get update && apt-get -y install ghostscript && apt-get clean