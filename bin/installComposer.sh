#!/bin/bash

BIN_DIRECTORY="${HOME}/.clubdrei/bin"

if [ "$EUID" -eq 0 ]; then
  echo "Abort - Do not run this script as root!"
  exit 1
fi

cd "${BIN_DIRECTORY}" || exit 1

EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [[ "${EXPECTED_CHECKSUM}" != "${ACTUAL_CHECKSUM}" ]]; then
  echo >&2 'ERROR: Invalid installer checksum'
  rm composer-setup.php
  exit 1
fi

if [[ ! -d "${BIN_DIRECTORY}" ]]; then
  mkdir -p "${BIN_DIRECTORY}"
fi

php composer-setup.php --install-dir="${BIN_DIRECTORY}" --quiet
RESULT=$?
mv "${BIN_DIRECTORY}/composer.phar" "${BIN_DIRECTORY}/composer"
chmod +x "${BIN_DIRECTORY}/composer"
rm composer-setup.php
exit ${RESULT}

# Downgrade to composer V1 for now. Some TYPO3 projects are not compatible with V2 yet.
"${BIN_DIRECTORY}/composer" self-update --1
