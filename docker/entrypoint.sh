#!/bin/sh
set -e

echo "=== Zaistock Container Starting ==="

echo "=== Checking PDO SSL constants ==="
php -r "
echo 'MYSQL_ATTR_SSL_KEY = ' . (defined('PDO::MYSQL_ATTR_SSL_KEY') ? PDO::MYSQL_ATTR_SSL_KEY : 'NOT DEFINED') . PHP_EOL;
echo 'MYSQL_ATTR_SSL_CERT = ' . (defined('PDO::MYSQL_ATTR_SSL_CERT') ? PDO::MYSQL_ATTR_SSL_CERT : 'NOT DEFINED') . PHP_EOL;
echo 'MYSQL_ATTR_SSL_CA = ' . (defined('PDO::MYSQL_ATTR_SSL_CA') ? PDO::MYSQL_ATTR_SSL_CA : 'NOT DEFINED') . PHP_EOL;
echo 'MYSQL_ATTR_SSL_CAPATH = ' . (defined('PDO::MYSQL_ATTR_SSL_CAPATH') ? PDO::MYSQL_ATTR_SSL_CAPATH : 'NOT DEFINED') . PHP_EOL;
echo 'MYSQL_ATTR_SSL_CIPHER = ' . (defined('PDO::MYSQL_ATTR_SSL_CIPHER') ? PDO::MYSQL_ATTR_SSL_CIPHER : 'NOT DEFINED') . PHP_EOL;
echo 'MYSQL_ATTR_SSL_VERIFY_SERVER_CERT = ' . (defined('PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT') ? PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT : 'NOT DEFINED') . PHP_EOL;
"

echo "=== Testing SSL with correct constants ==="
php -r "
\$host = getenv('DB_HOST');
\$port = getenv('DB_PORT');
\$db = getenv('DB_DATABASE');
\$user = getenv('DB_USERNAME');
\$pass = getenv('DB_PASSWORD');
\$ca = '/etc/ssl/certs/ca-certificates.crt';

\$sslCa = defined('PDO::MYSQL_ATTR_SSL_CA') ? PDO::MYSQL_ATTR_SSL_CA : 1012;
\$sslVerify = defined('PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT') ? PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT : 1015;

echo 'Using SSL_CA=' . \$sslCa . ', VERIFY=' . \$sslVerify . PHP_EOL;

echo PHP_EOL . 'Test 1: Correct constants + ssl-mode=REQUIRED...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db;ssl-mode=REQUIRED\";
    \$pdo = new PDO(\$dsn, \$user, \$pass, [
        \$sslCa => \$ca,
        \$sslVerify => true,
    ]);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}

echo PHP_EOL . 'Test 2: Correct constants only (no ssl-mode)...' . PHP_EOL;
try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
    \$pdo = new PDO(\$dsn, \$user, \$pass, [
        \$sslCa => \$ca,
        \$sslVerify => true,
    ]);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}

echo PHP_EOL . 'Test 3: All 3 SSL options...' . PHP_EOL;
try {
    \$sslKey = defined('PDO::MYSQL_ATTR_SSL_KEY') ? PDO::MYSQL_ATTR_SSL_KEY : 1010;
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
    \$pdo = new PDO(\$dsn, \$user, \$pass, [
        \$sslCa => \$ca,
        \$sslVerify => true,
        3 => true,
    ]);
    echo 'SUCCESS!' . PHP_EOL;
} catch (Exception \$e) {
    echo 'Failed: ' . \$e->getMessage() . PHP_EOL;
}
"

echo "=== Done ==="
exit 1
