#!/bin/sh
set -e

echo "=== Zaistock Container Starting ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "DATABASE_URL: $DATABASE_URL"

# Check if CA cert exists
echo "=== CA cert check ==="
ls -la /etc/ssl/certs/ca-certificates.crt 2>&1 || echo "CA cert NOT FOUND"

# Cache configs (env vars are available at runtime)
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "=== Testing DB connection ==="
php -r "
\$config = include '/var/www/html/bootstrap/cache/config.php';
\$db = \$config['database']['connections']['mysql'];
echo 'Driver: ' . \$db['driver'] . PHP_EOL;
echo 'Host: ' . \$db['host'] . PHP_EOL;
echo 'Port: ' . \$db['port'] . PHP_EOL;
echo 'Database: ' . \$db['database'] . PHP_EOL;
echo 'URL: ' . (\$db['url'] ?? 'not set') . PHP_EOL;
echo 'Options: ' . print_r(\$db['options'] ?? [], true) . PHP_EOL;

echo PHP_EOL . 'Attempting PDO connection...' . PHP_EOL;
try {
    \$dsn = 'mysql:host=' . \$db['host'] . ';port=' . \$db['port'] . ';dbname=' . \$db['database'];
    echo 'DSN: ' . \$dsn . PHP_EOL;
    \$pdo = new PDO(\$dsn, \$db['username'], \$db['password'], [
        1014 => '/etc/ssl/certs/ca-certificates.crt',
    ]);
    echo 'Connected successfully!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Connection failed: ' . \$e->getMessage() . PHP_EOL;
    echo 'Trying with ssl-mode=REQUIRED in DSN...' . PHP_EOL;
    try {
        \$dsn2 = 'mysql:host=' . \$db['host'] . ';port=' . \$db['port'] . ';dbname=' . \$db['database'] . ';ssl-mode=REQUIRED';
        echo 'DSN: ' . \$dsn2 . PHP_EOL;
        \$pdo = new PDO(\$dsn2, \$db['username'], \$db['password']);
        echo 'Connected with ssl-mode=REQUIRED!' . PHP_EOL;
    } catch (Exception \$e2) {
        echo 'Still failed: ' . \$e2->getMessage() . PHP_EOL;
    }
}
"

echo "=== Running migrations ==="
# Run migrations
php artisan migrate --force

# Create storage link
php artisan storage:link 2>/dev/null || true

echo "=== Starting server ==="

# Start Supervisor (runs both Nginx and PHP-FPM)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
