#!/bin/sh
set -e

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
