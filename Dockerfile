FROM ubuntu:18.04

# RETRIEVE ARGUMENT FOR PHP VERSION AND ASSIGN A DEFAULT IF NOT FOUND
ARG PHP_VERSION=7.3

# RETRIEVE ARGUMENT FOR PHPDOX INSTALLATION, ASSIGN DEFAULT VALUE AND CREATES AN ENV VARIABLE INSIDE THE CONTAINER
ARG INSTALL_PHPDOX=false
ENV INSTALL_PHPDOX=${INSTALL_PHPDOX}

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
RUN apt-get install -y php${PHP_VERSION}
RUN apt-get install -q -y   git  \
  unzip \
  wget  \
  zip \
  zlib1g-dev \
  php${PHP_VERSION}-bcmath  \
  php${PHP_VERSION}-gd  \
  php${PHP_VERSION}-mysqli \
  php${PHP_VERSION}-pdo  \
  php${PHP_VERSION}-zip \
  php-pear php${PHP_VERSION}-dev \
  php${PHP_VERSION}-xml \
  libxml2 \
  curl \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-xmlrpc \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-json \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-bz2 \
  php${PHP_VERSION}-zip \
  php${PHP_VERSION}-soap \
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
# PLEASE NOTE THAT AWS CLI V2 HAS BEEN INSTALLED , NOT V1 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
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
COPY files/xdebug.ini /etc/php/${PHP_VERSION}/mods-available/xdebug.ini
COPY files/imagick.ini /etc/php/${PHP_VERSION}/mods-available/imagick.ini
COPY files/memcached.ini /etc/php/${PHP_VERSION}/mods-available/memcached.ini

RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/
RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/apache2/conf.d/
RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/imagick.ini /etc/php/${PHP_VERSION}/cli/conf.d/
RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/imagick.ini /etc/php/${PHP_VERSION}/apache2/conf.d/
RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/memcached.ini /etc/php/${PHP_VERSION}/cli/conf.d/
RUN  ln -sf /etc/php/${PHP_VERSION}/mods-available/memcached.ini /etc/php/${PHP_VERSION}/apache2/conf.d/


# HOW COULD I FORGOT? THE BEST EDITOR IN THE WORLD!
RUN apt-get install -q -y nano

# CREATE A DEFAULT WEBPAGE WITH SOME INFO
RUN rm /var/www/html/index.html
RUN echo "<?php phpinfo();" > /var/www/html/index.php

# SET APACHE DOMAIN NAME
RUN echo "ServerName localhost" > /etc/apache2/conf-enabled/fqdn.conf



# INSTALL PHPDOX AND SOME OTHER STUFF IF REQUIRED (this is failing for a domain not found: static.phpmd.org)
# I'M NOT SURE WE NEED THIS STUFF AT THIS STAGE BUT...
# PS SHELL IF STATEMENTS ARE PICKY PLEASE BE CAREFUL WITH SPACES AND SYNTAX!
RUN if [ $INSTALL_PHPDOX = true ]; then \
  wget https://phar.phpunit.de/phploc.phar && \
  chmod +x phploc.phar && \
  mv phploc.phar /usr/local/bin/phploc && \
  wget http://phpdox.de/releases/phpdox.phar && \
  chmod +x phpdox.phar && \
  mv phpdox.phar /usr/local/bin/phpdox && \
  wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
  chmod +x phpcs.phar && \
  mv phpcs.phar /usr/local/bin/phpcs && \
  wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && \
  chmod +x phpcbf.phar && \
  mv phpcbf.phar /usr/local/bin/phpcbf && \
  wget -c http://static.phpmd.org/php/latest/phpmd.phar && \
  chmod +x phpmd.phar && \
  mv phpmd.phar /usr/local/bin/phpmd; \
fi


# Install ping and stop
RUN apt-get install -q -y iputils-ping htop


# clean
RUN apt autoremove -q -y

EXPOSE 80 443
WORKDIR /var/www/

CMD apachectl -D FOREGROUND
