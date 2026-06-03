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

# Start Supervisor (Nginx + PHP-FPM) in background
# This binds port 80 immediately so Render detects it
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for Nginx to be ready
sleep 3

# Run migrations
php artisan migrate --force

# Create storage link
php artisan storage:link 2>/dev/null || true

# Bring Supervisor to foreground (keeps container alive)
wait
