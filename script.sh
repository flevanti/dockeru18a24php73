#!/usr/bin/env bash
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi


set -e

export DEBIAN_FRONTEND=noninteractive

$SUDO apt-get update -y
$SUDO apt-get upgrade -y

$SUDO apt-get install openssl -y
$SUDO apt-get install apt-utils -y
$SUDO apt-get install nano -y
$SUDO apt-get install python3-pip -y
$SUDO apt-get install  software-properties-common -y
$SUDO apt-get install zip unzip -y

$SUDO LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2 -y
$SUDO LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y

$SUDO apt-get update -y

$SUDO apt-get install apache2 -y
$SUDO a2enmod rewrite mime headers
$SUDO chown -R ubuntu:www-data /var/www
$SUDO chmod -R 775 /var/www
$SUDO usermod -a -G www-data ubuntu
$SUDO chown -R ubuntu:www-data /etc/apache2/sites-available
$SUDO chown -R ubuntu:www-data /etc/apache2/conf-available


$SUDO apt-get install php7.3 -y
$SUDO apt-get install php7.3-mbstring -y
$SUDO apt-get install php7.3-curl -y
$SUDO apt-get install php7.3-xml -y
$SUDO apt-get install php7.3-zip -y
$SUDO apt-get install php-memcached -y
$SUDO apt-get install php7.3-mysql -y

pip3 install awscli --upgrade --user

echo "ServerName localhost" > ./fqdn.conf
$SUDO mv ./fqdn.conf /etc/apache2/conf-enabled/fqdn.conf

echo "<?php echo 'RF';" > /var/www/html/index.php

if [ -f /var/www/html/index.html ]; then
   mv /var/www/html/index.html /var/www/html/index_old.html
fi

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
$SUDO mv composer.phar /usr/local/bin/composer

$SUDO apt-get dist-upgrade -y

echo "PLEASE REBOOT THIS INSTANCE, KERNEL HAS BEEN UPGRADED"


