#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})

cd $SCRIPT_PATH/../../../ || exit

# Prepare services configuration
make setup
make addbasicservices
make file=services/selenium-chrome.yml addservice

# Configure containers
perl -pi\
  -e 's#error_reporting = .*#error_reporting = E_ALL ^ E_WARNING ^ E_DEPRECATED#g;'\
  containers/php-fpm/custom.ini

$SCRIPT_PATH/../parts/shared/prepare_shop_package.sh -e"CE" -b"b-7.0.x"
$SCRIPT_PATH/../parts/shared/require_twig_components.sh -e"CE" -b"b-7.0.x"
$SCRIPT_PATH/../parts/shared/require_theme.sh -t"twig" -b"b-7.0.x"

git clone https://github.com/Fresh-Advance/Sitemap source/dev-packages/sitemap
docker-compose exec \
  php composer config repositories.fresh-advance/sitemap \
  --json '{"type":"path", "url":"./dev-packages/sitemap", "options": {"symlink": true}}'
docker-compose exec php composer require fresh-advance/sitemap:* --no-update

$SCRIPT_PATH/../parts/shared/require_demodata_package.sh -e"CE" -b"b-7.0.x"

# Install all preconfigured dependencies
docker-compose exec -T php composer update --no-interaction

$SCRIPT_PATH/../parts/shared/setup_database.sh

docker-compose exec -T php bin/oe-console oe:module:activate fa_sitemap
docker-compose exec -T php bin/oe-console oe:theme:activate twig

$SCRIPT_PATH/../parts/shared/create_admin.sh

echo "Done!"