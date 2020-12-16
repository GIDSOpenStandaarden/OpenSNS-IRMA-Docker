#!/usr/bin/env bash

# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

function check_variable {
  eval "VAL=\"\$$1\""
  if [ -z "$VAL" ]; then
    echo "The environment variable $1 is required."
    exit 1
  fi
}

check_variable "HOST_URL"
check_variable "JWT_ISSUER"
check_variable "CLIENT_KEY"

## Check if there is a private key file added to the container and set in JWT_PRIVATE_KEY_FILE.
if [ ! -s "$JWT_PRIVATE_KEY_FILE" ]; then
  ## Check if a value is given in JWT_PRIVATE_KEY.
  if [ -z "$JWT_PRIVATE_KEY" ]; then
    echo "Generating keypair becasue envorionment variable JWT_PRIVATE_KEY environment variable is not set"
    bash /tools/keygen.sh "$JWT_PUBLIC_KEY_FILE" "$JWT_PRIVATE_KEY_FILE"
  else
    echo "Using keys from JWT_PUBLIC_KEY and JWT_PRIVATE_KEY because JWT_PRIVATE_KEY is set (the public key is not required)"
    if [ -n "$JWT_PUBLIC_KEY" ]; then
      echo "$JWT_PUBLIC_KEY" >"$JWT_PUBLIC_KEY_FILE"
    fi
    echo "$JWT_PRIVATE_KEY" >"$JWT_PRIVATE_KEY_FILE"
  fi
fi

if [ -s "$JWT_PUBLIC_KEY_FILE" ]; then
  # Note that the public key file is only used for logging here, the server does not need one.
  echo "The public key is set to:"
  cat "$JWT_PUBLIC_KEY_FILE"
  echo ""
fi

if [ -z "$CLIENT_SECRET" ]; then
  echo "Generating client secret becasue CLIENT_SECRET environment variable is not set:"
  export CLIENT_SECRET="$(openssl rand -hex 32)"
  echo "$CLIENT_SECRET"
  echo ""
fi

# Use envsubst to dereference the variables
mv /configuration/configuration.json /configuration/configuration.json.tmp
envsubst </configuration/configuration.json.tmp >/configuration/configuration.json

if [ $DEBUG -gt 0 ]; then
echo "/configuration/configuration.json"
cat /configuration/configuration.json
echo ""
cat "$JWT_PUBLIC_KEY_FILE"
echo ""
fi

# Download the schemes
mkdir -p /configuration/schemes
if [ -n "$SCHEMES" ]; then
  IFS=$' '
  for SCHEME in $SCHEMES; do
    echo "Downloading scheme $SCHEME"
    /usr/local/bin/irma scheme download /configuration/schemes "$SCHEME"
  done
fi

/usr/local/bin/irma server -c /configuration/configuration.json
