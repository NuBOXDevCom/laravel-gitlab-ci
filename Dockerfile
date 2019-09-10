FROM debian:buster
LABEL maintainer="slye@nubox.fr"

RUN apt-get update && apt-get dist-upgrade -yq && apt-get install -yq --fix-missing locales ntp ntpdate apt-utils && locale-gen fr_FR.UTF-8

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV LC_ALL fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV DISPLAY :99
ENV SCREEN_RESOLUTION 1920x720x24
ENV PATH="${PATH}:/root/.composer/vendor/bin"
ENV TMPDIR=/tmp

RUN apt-get install -yq --fix-missing wget curl zip unzip git software-properties-common ssh-askpass \
    zip unzip openssl libgd-tools imagemagick mc lynx bzip2 make g++ \
    ca-certificates apt-transport-https redis-server curl git-extras git-flow gconf2 \
    python3-software-properties build-essential gnupg libpq-dev mariadb-client

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN apt-get update && apt-get dist-upgrade -yq && apt-get install -yq --fix-missing php7.3 php7.3-bcmath php7.3-bz2 php7.3-cli php7.3-common php7.3-curl \
    php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-intl php7.3-mysql \
    php7.3-opcache php7.3-pgsql php7.3-pspell php7.3-readline php7.3-recode \
    php7.3-soap php7.3-sqlite3 php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-xsl php7.3-mbstring \
    php7.3-zip php-memcached php-redis libpng-dev jpegoptim optipng pngquant gifsicle

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer && composer global require hirak/prestissimo && composer global require laravel/envoy --no-progress --no-suggest

ADD commands/configure-laravel.sh /usr/bin/configure-laravel
RUN chmod +x /usr/bin/configure-laravel

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -yq nodejs

RUN wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit

RUN apt-get -yq clean && apt-get clean all && apt-get autoclean -yq \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get dist-upgrade && apt-get autoremove -yq
