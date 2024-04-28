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

perl -pi\
  -e 's#/var/www/#/var/www/source/#g;'\
  containers/httpd/project.conf

perl -pi\
  -e 's#PHP_VERSION=.*#PHP_VERSION=8.1#g;'\
  .env

mkdir source
docker compose up --build -d php

cp ${SCRIPT_PATH}/../parts/bases/composer.json.base ./source/composer.json

docker compose exec php composer config repositories.oxid-esales/oxideshop-ce git https://github.com/OXID-eSales/oxideshop_ce.git
docker compose exec php composer require oxid-esales/oxideshop-ce:dev-b-7.0.x --no-update

docker compose exec php composer require oxid-esales/developer-tools:dev-b-7.0.x --no-update

docker compose exec php composer config repositories.fresh-advance/invoice git https://github.com/Fresh-Advance/Invoice.git
docker compose exec php composer require fresh-advance/invoice:dev-b-7.0.x --no-update

$SCRIPT_PATH/../parts/shared/require_twig_components.sh -e"CE" -b"b-7.0.x"
$SCRIPT_PATH/../parts/shared/require_theme.sh -t"twig" -b"b-7.0.x"

$SCRIPT_PATH/../parts/shared/require_demodata_package.sh -e"CE" -b"b-7.0.x"

docker compose exec php composer update --no-interaction

make up

$SCRIPT_PATH/../parts/shared/setup_database.sh

docker compose exec -T php vendor/bin/oe-console oe:module:activate fa_invoice
docker compose exec -T php vendor/bin/oe-console oe:theme:activate twig

$SCRIPT_PATH/../parts/shared/create_admin.sh

# Register all related project packages git repositories
mkdir -p .idea; cp "${SCRIPT_PATH}/../parts/bases/vcs.xml.base" .idea/vcs.xml
perl -pi\
  -e 's#</component>#<mapping directory="\$PROJECT_DIR\$/source/vendor/fresh-advance/invoice" vcs="Git" />\n  </component>#g;'\
  .idea/vcs.xml