FROM ubuntu:18.04


ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# REFRESH PACKAGES LIST
RUN apt-get update -q -y

# ADD ADDITIONAL PACKAGE REPOSITORY FOR APACHE2 AND PHP (@see https://launchpad.net/~ondrej )
RUN apt-get install -q -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2

# REFRESH PACKAGES LIST AGAIN TO RETRIEVE THE NEW PACKAGES FROM NEW REPOS (is it needed??)
RUN apt-get update -q -y


RUN apt-get install -y apache2
RUN apt-get install -y php7.3
RUN apt-get install -q -y   git  \
  unzip \
  wget  \
  zip \
  zlib1g-dev \
  php7.3-bcmath  \
  php7.3-gd  \
  php7.3-mysqli \
  php7.3-pdo  \
  php7.3-zip \
  php-pear php7.3-dev \
  php7.3-xml \
  libxml2 \
  curl \
  php7.3-curl \
  php7.3-mbstring \
  php7.3-xmlrpc \
  php7.3-bcmath \
  php7.3-cli \
  php7.3-json \
  php7.3-bcmath \
  php7.3-bz2 \
  php7.3-zip \
  ssmtp \
  php-mail \
  screen

# INSTALL IMAGICK PACKAGE AND EXTENSION
RUN apt-get install -q -y libmagickwand-dev --no-install-recommends
RUN pecl install imagick

# INSTALL XDEBUG
RUN pecl install xdebug
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# create a link to python bin it looks like the system doesn't have a generic one
RUN  ln -sf /usr/bin/python3 /usr/bin/python

# INSTALL AWS CLI TOOLS
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip 
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN aws --version


# INSTALL MEMCACHED
RUN apt-get install -q -y gcc make autoconf libc-dev pkg-config zlib1g-dev libmemcached-dev
RUN pecl install memcached-3.1.3

# INSTALL PHPUNIT AND MAKE IT EXECUTABLE
RUN wget -O phpunit https://phar.phpunit.de/phpunit-8.phar && chmod +x phpunit &&  mv phpunit /usr/local/bin/phpunit

# ENABLE APACHE2 MODULES
RUN a2enmod rewrite
RUN a2enmod headers

# COPY PHP INI FILES IN MODS AVAILABLE FOLDER AND THEN ENABLE THEM
COPY files/xdebug.ini /etc/php/7.3/mods-available/xdebug.ini
COPY files/imagick.ini /etc/php/7.3/mods-available/imagick.ini
RUN  ln -sf /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/cli/conf.d/
RUN  ln -sf /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/apache2/conf.d/
RUN  ln -sf /etc/php/7.3/mods-available/imagick.ini /etc/php/7.3/cli/conf.d/
RUN  ln -sf /etc/php/7.3/mods-available/imagick.ini /etc/php/7.3/apache2/conf.d/


# HOW COULD I FORGOT? THE BEST EDITOR IN THE WORLD!
RUN apt-get install -q -y nano

# CREATE A DEFAULT WEBPAGE WITH SOME INFO
RUN rm /var/www/html/index.html
RUN echo "<?php phpinfo();" > /var/www/html/index.php

# SET APACHE DOMAIN NAME
RUN echo "ServerName localhost" > /etc/apache2/conf-enabled/fqdn.conf


EXPOSE 80 443
WORKDIR /var/www/

CMD apachectl -D FOREGROUND
