FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt-get dist-upgrade -y

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y software-properties-common

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update -y

RUN apt-get install apache2 -y

RUN apt-get install php7.3 -y
RUN apt-get install php7.3-mbstring -y

RUN apt-get install openssl -y

RUN apt-get install apt-utils -y
RUN apt-get install nano -y

RUN rm /var/www/html/index.html
RUN echo "<?php phpinfo();" > /var/www/html/index.php

RUN echo "ServerName localhost" > /etc/apache2/conf-enabled/fqdn.conf

COPY ./start_service.sh /root/start_service.sh
CMD ["sh", "/root/start_services.sh"]
