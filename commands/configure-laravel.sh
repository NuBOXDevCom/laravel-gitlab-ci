#!/bin/bash
cd ${CI_PROJECT_DIR}
chown -R www-data:www-data *
chmod -R ug+rwx storage bootstrap/cache
php artisan optimize:clear