#!/bin/bash -e

newpass() {
  LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c${1:-48}
}

echo "ENCRYPTION_KEY=$(newpass)"
echo "ENCRYPTION_DETERMINISTIC_KEY=$(newpass)"
echo "ENCRYPTION_KEY_DERIVATION_SALT=$(newpass)"

