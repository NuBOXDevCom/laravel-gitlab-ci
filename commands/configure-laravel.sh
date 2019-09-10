#!/bin/bash
cd ${CI_PROJECT_DIR}
chgrp -R www-data *
chmod -R ug+rwx storage bootstrap/cache
php artisan optimize:clear
php artisan key:generate