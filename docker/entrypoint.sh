#!/bin/sh
set -e

echo "=== Zaistock Container Starting ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"

# Ensure cache directories exist
mkdir -p bootstrap/cache
mkdir -p storage/framework/views
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/logs
chmod -R 777 bootstrap/cache
chmod -R 777 storage

echo "=== Testing SSL connections ==="
php -r "
\$host = getenv('DB_HOST');
\$port = getenv('DB_PORT');
\$db = getenv('DB_DATABASE');
\$user = getenv('DB_USERNAME');
\$pass = getenv('DB_PASSWORD');
\$ca = '/etc/ssl/certs/ca-certificates.crt';

echo 'Test 1: ssl-mode + PDO SSL options...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db;ssl-mode=REQUIRED\";
    \$pdo = new PDO(\$dsn, \$user, \$pass, [
        1014 => \$ca,
        1015 => true,
    ]);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}

echo PHP_EOL . 'Test 2: Only PDO options (no ssl-mode in DSN)...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
    \$pdo = new PDO(\$dsn, \$user, \$pass, [
        3    => true,
        1014 => \$ca,
        1015 => true,
    ]);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}

echo PHP_EOL . 'Test 3: ssl-mode=VERIFY_CA...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db;ssl-mode=VERIFY_CA;ssl-ca=\$ca\";
    \$pdo = new PDO(\$dsn, \$user, \$pass);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}

echo PHP_EOL . 'Test 4: ssl-mode=VERIFY_IDENTITY...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db;ssl-mode=VERIFY_IDENTITY;ssl-ca=\$ca\";
    \$pdo = new PDO(\$dsn, \$user, \$pass);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}
"

echo "=== Done testing ==="
exit 1
