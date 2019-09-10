FROM debian:buster
LABEL maintainer="slye@nubox.fr"

RUN apt update && && apt dist-upgrade -yq apt install -yq locales ntp ntpdate && locale-gen fr_FR.UTF-8

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV LC_ALL fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV DISPLAY :99
ENV SCREEN_RESOLUTION 1920x720x24
ENV CHROMEDRIVER_PORT 9515
ENV PATH="${PATH}:/root/.composer/vendor/bin"
ENV TMPDIR=/tmp

RUN apt install -yq --fix-missing wget curl zip unzip git software-properties-common ssh-askpass \
    apt-utils zip unzip openssl libgd-tools imagemagick mc lynx mysql-client bzip2 make g++ nginx-full \
    ca-certificates apt-transport-https redis-server curl git-extras git-flow xvfb gconf2 \
    fonts-ipafont-gothic xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable \
    python3-software-properties build-essential

RUN chmod +x /etc/init.d/xvfb

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN apt update && apt dist-upgrade -yq && apt install -yq --fix-missing php7.3 php7.3-bcmath php7.3-bz2 php7.3-cli php7.3-common php7.3-curl \
  php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-intl php7.3-mysql \
  php7.3-opcache php7.3-pgsql php7.3-pspell php7.3-readline php7.3-recode \
  php7.3-soap php7.3-sqlite3 php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-xsl \
  php7.3-zip php-memcached php-redis php-openssl supervisor libpng-dev jpegoptim optipng pngquant gifsicle

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer && composer global require laravel/envoy --no-progress --no-suggest

ADD commands/xvfb.init.sh /etc/init.d/xvfb

ADD commands/start-nginx-ci-project.sh /usr/bin/start-nginx-ci-project

RUN chmod +x /usr/bin/start-nginx-ci-project
ADD commands/configure-laravel.sh /usr/bin/configure-laravel
RUN chmod +x /usr/bin/configure-laravel

RUN \
  apt install -yq xvfb gconf2 fonts-ipafont-gothic xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base \
    xfonts-scalable \
  && chmod +x /etc/init.d/xvfb \
  && CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
  && mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION \
  && curl -sS -o /tmp/chromedriver_linux64.zip \
    http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
  && unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION \
  && rm /tmp/chromedriver_linux64.zip \
  && chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver \
  && ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver \
  && curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt -yqq update && apt -yqq install google-chrome-stable x11vnc

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt install -yq nodejs

RUN wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit

ADD configs/supervisord.conf /etc/supervisor/supervisord.conf

ADD configs/nginx-default-site /etc/nginx/sites-available/default 

VOLUME [ "/var/log/supervisor" ]

RUN apt -yq clean && apt clean all && apt autoclean -yq \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt dist-upgrade && apt autoremove -yq \
    && php --version \
    && composer --version \
    && nginx -v \
    && phpunit --version \
    && nodejs --version \
    && npm --version \
    && envoy -V

EXPOSE 80 9515 3306

WORKDIR /var/www/html/

CMD ["nginx", "-g", "daemon off;"]