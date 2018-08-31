#!/bin/sh

if [ -d /var/lib/mysql/mysql ]; then
    echo "[i] MySQL directory already present, skipping creation"

    nohup /usr/bin/mysqld_safe --datadir='/var/lib/mysql' --user=root --console &
else
    echo "[i] MySQL data directory not found, creating initial DBs"

    mysql_install_db --user=root --console

    echo "Starting mysql process"
    nohup /usr/bin/mysqld_safe --datadir='/var/lib/mysql' --user=root --console &

    echo "[i] Sleeping 5 sec"
    sleep 5

    echo >> /usr/local/bin/setup.sql

#    echo "insert core_config_data (config_id, scope, scope_id, path, value) values (null, 'default', 0, 'dev/static/sign', 0);" >> /usr/local/bin/setup.sql

    if [ "$MYSQL_DATABASE" != "" ]; then
        echo "[i] Creating database: $MYSQL_DATABASE"
        echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;" >> /usr/local/bin/setup.sql
    fi

    echo "Updating data"
    /usr/bin/mysql --user=root < /usr/local/bin/setup.sql

    echo "Set mysql root password: $MYSQL_ROOT_PASSWORD"
    /usr/bin/mysqladmin -u root password $MYSQL_ROOT_PASSWORD
fi

if [ ! -d /var/www/magento2/update ]; then
    echo "Create composer project"
    composer create-project --repository=https://repo.magento.com/ magento/project-community-edition /var/www/magento2
fi

if [ ! -f /vaw/www/magento2/bin/magento ]; then
    echo "Magento setup:install"
    bin/magento setup:install \
        --base-url=$MAGENTO_BASE_URL \
        --db-host=127.0.0.1 \
        --db-name=$MYSQL_DATABASE \
        --db-user=root \
        --db-password=$MYSQL_ROOT_PASSWORD \
        --backend-frontname=admin \
        --admin-firstname=admin \
        --admin-lastname=admin \
        --admin-email=admin@admin.com \
        --admin-user=admin \
        --admin-password=admin123 \
        --language=en_US \
        --currency=USD \
        --use-rewrites=1 \

fi

    composer config repositories.module-custom-catalog vcs https://github.com/marina-bard/module-custom-catalog.git
    composer require magento/module-custom-catalog dev-master

    echo "Update --base-url config to $MAGENTO_BASE_URL"
    bin/magento setup:store-config:set --base-url="$MAGENTO_BASE_URL"

    echo "Set ownership and permissions. Execute chown -R :nobody ."
    chown -R :nobody .

    echo "Execute find . -type d -exec chmod g+ws {} \;"
    find . -type d -exec chmod g+ws {} \;

    echo "Execute rm -rf var/cache/* var/page_cache/* var/generation/*"
    rm -rf var/cache/* var/page_cache/* var/generation/*

    echo "Execute bin/magento setup:upgrade"
    bin/magento setup:upgrade

    echo "Execute bin/magento setup:di:compile"
    bin/magento setup:di:compile

    echo "Execute bin/magento cache:clean"
    bin/magento cache:clean

    echo "Execute bin/magento setup:config:set to set rabbitmq custom config values"
    echo "\t host=$RABBITMQ_HOST"
    echo "\t port=$RABBITMQ_PORT"
    echo "\t user=$RABBITMQ_USER"
    echo "\t password=$RABBITMQ_PASSWORD"

    bin/magento setup:config:set --amqp-host="$RABBITMQ_HOST" --amqp-port="$RABBITMQ_POPT" --amqp-user="$RABBITMQ_USER" --amqp-password="$RABBITMQ_PASSWORD"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"

echo "Starting php-fpm"
/usr/sbin/php-fpm7 --daemonize

echo "Starting nginx"
nginx -g 'daemon off;'