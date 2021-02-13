#!/bin/bash

EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [[ "${EXPECTED_CHECKSUM}" != "${ACTUAL_CHECKSUM}" ]]; then
  echo >&2 'ERROR: Invalid installer checksum'
  rm composer-setup.php
  exit 1
fi

php composer-setup.php --install-dir="${HOME}/.local/bin" --quiet
RESULT=$?
mv "${HOME}/.local/bin/composer.phar" "${HOME}/.local/bin/composer"
rm composer-setup.php
exit ${RESULT}

# Downgrade to composer V1 for now. Some TYPO3 projects are not compatible with V2 yet.
"${HOME}/.local/bin/composer" self-update --1
