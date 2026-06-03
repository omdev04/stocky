#!/bin/sh
set -e

echo "=== Zaistock Container Starting ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"

# Cache configs (env vars are available at runtime)
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "=== Config cached, running migrations ==="

# Run migrations
php artisan migrate --force

# Create storage link
php artisan storage:link 2>/dev/null || true

echo "=== Migrations done, starting server ==="

# Start Supervisor (runs both Nginx and PHP-FPM)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
