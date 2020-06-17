FROM ubuntu:xenial

RUN apt-get update -y && apt-get install -y --no-install-recommends software-properties-common git curl cron npm zip unzip ca-certificates apt-transport-https lsof mcrypt libmcrypt-dev libreadline-dev wget sudo nginx nodejs build-essential unixodbc-dev

# Install PHP Repo
RUN LANG=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    ## Update the system
    apt-get update && apt-get install -y --no-install-recommends --allow-unauthenticated \
    ## PHP Dependencies and PECL
    php7.2-common \
    php7.2-xml \
    php7.2-cli \
    php7.2-curl \
    php7.2-json \
    php7.2-mysqlnd \
    php7.2-sqlite \
    php7.2-soap \
    php7.2-mbstring \
    php7.2-zip \
    php7.2-bcmath \
    php7.2-dev \
    php7.2-ldap \
    php7.2-pgsql \
    php7.2-interbase \
    php7.2-gd \
    php7.2-sybase \
    php7.2-fpm \
    php-pear \
    php-pecl-http && \
    pecl channel-update pecl.php.net && \
    pecl install mcrypt-1.0.1 && \
    pecl install mongodb && \
    pecl install igbinary && \
    pecl install pcs-1.3.3 && \
    pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    ## Install Python2 Bunch & Python3 Munch
    apt install -y --no-install-recommends --allow-unauthenticated python python-pip python3 python3-pip python-setuptools python3-setuptools && \
    pip install bunch && \
    pip3 install munch && \
    ## Install Async and Lodash
    npm install -g async lodash

# Additional Drivers
RUN apt-get update && \
    ## MCrypt 
    echo "extension=mcrypt.so" >"/etc/php/7.2/mods-available/mcrypt.ini" && \
    phpenmod -s ALL mcrypt && \
    ## IGBINARY
    echo "extension=igbinary.so" >"/etc/php/7.2/mods-available/igbinary.ini" && \
    phpenmod -s ALL igbinary && \
    ## PCS
    echo "extension=pcs.so" >"/etc/php/7.2/mods-available/pcs.ini" && \
    phpenmod -s ALL pcs && \
    ## MongoDB
    echo "extension=mongodb.so" >"/etc/php/7.2/mods-available/mongodb.ini" && \
    phpenmod -s ALL mongodb && \
    ## Install MS SQL Drivers
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list >/etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    echo "extension=sqlsrv.so" >"/etc/php/7.2/mods-available/sqlsrv.ini" && \
    phpenmod -s ALL sqlsrv && \
    ## DRIVERS FOR MSSQL (pdo_sqlsrv)
    echo "extension=pdo_sqlsrv.so" >"/etc/php/7.2/mods-available/pdo_sqlsrv.ini" && \
    phpenmod -s ALL pdo_sqlsrv && \
    ## Node
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y --no-install-recommends --allow-unauthenticated nodejs && \
    ## Install Composer
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    ## Configure Sendmail
    echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /etc/php/7.2/cli/conf.d/mail.ini

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*