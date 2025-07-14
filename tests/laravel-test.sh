#!/bin/bash

set -e

LARAVEL_VERSION_CONSTRAINT="${1:-^11.0}"

echo "Install Laravel ${LARAVEL_VERSION_CONSTRAINT}"
composer create-project --quiet --prefer-dist "laravel/laravel:${LARAVEL_VERSION_CONSTRAINT}" ../laravel
cd ../laravel/
SAMPLE_APP_DIR="$(pwd)"
composer show --direct

echo "Add Emmanuel Larastan Laravel 12 from source"
composer config minimum-stability dev
composer config repositories.0 '{ "type": "path", "url": "../larastan", "options": { "symlink": false } }'

# No version information with "type":"path"
composer require --dev --optimize-autoloader "emmanuel/larastan-laravel-12:*"

cat >phpstan.neon <<"EOF"
includes:
    - ./vendor/emmanuel/larastan-laravel-12/extension.neon
parameters:
    level: 5
    paths:
        - app/
EOF

echo "Test Laravel"
vendor/bin/phpstan analyse

echo "Test Laravel from another working directory"
cd /tmp/
${SAMPLE_APP_DIR}/vendor/bin/phpstan analyse --configuration=${SAMPLE_APP_DIR}/phpstan.neon
