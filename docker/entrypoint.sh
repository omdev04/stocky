#!/bin/sh
set -e

# Ensure cache directories exist
mkdir -p bootstrap/cache
mkdir -p storage/framework/views
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/logs
chmod -R 775 bootstrap/cache
chmod -R 775 storage

# Cache configs (env vars are available at runtime)
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
php artisan migrate --force

# Create storage link
php artisan storage:link 2>/dev/null || true

# Start Supervisor (runs both Nginx and PHP-FPM)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
