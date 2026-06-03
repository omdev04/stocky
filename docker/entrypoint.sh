#!/bin/sh
set -e

echo "=== Zaistock Container Starting ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DATABASE_URL: $DATABASE_URL"

# Ensure cache directories exist
mkdir -p bootstrap/cache
mkdir -p storage/framework/views
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/logs
chmod -R 775 bootstrap/cache
chmod -R 775 storage

# Cache configs
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Verify config cache was created
ls -la bootstrap/cache/config.php 2>&1 || echo "WARNING: config.php not created!"

echo "=== Testing DB with ssl-mode=REQUIRED ==="
php -r "
try {
    \$dsn = 'mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT') . ';dbname=' . getenv('DB_DATABASE') . ';ssl-mode=REQUIRED';
    echo 'DSN: ' . \$dsn . PHP_EOL;
    \$pdo = new PDO(\$dsn, getenv('DB_USERNAME'), getenv('DB_PASSWORD'));
    echo 'SUCCESS: Connected with ssl-mode=REQUIRED!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}
"

echo "=== Running migrations ==="
php artisan migrate --force

# Create storage link
php artisan storage:link 2>/dev/null || true

echo "=== Starting server ==="
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
