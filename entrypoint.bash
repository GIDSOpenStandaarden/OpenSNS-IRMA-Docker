#!/usr/bin/env bash

# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

echo "HOST_URL is ${HOST_URL}"
echo "JWT_ISSUER is ${JWT_ISSUER}"
echo "CLIENT_KEY is ${CLIENT_KEY}"

if [ -s "$JWT_PUBLIC_KEY_FILE" ]; then
  # Note that the public key file is only used for logging here, the server does not need one.
  echo "The public key is set to:"
  cat "$JWT_PUBLIC_KEY_FILE"
  echo ""
else
  echo "The public key file ${JWT_PUBLIC_KEY_FILE} is not found."
  exit 1
fi

# Use envsubst to dereference the variables
mv /configuration/configuration.json /configuration/configuration.json.tmp
envsubst </configuration/configuration.json.tmp >/configuration/configuration.json

if [ $DEBUG -gt 0 ]; then
echo "/configuration/configuration.json"
cat /configuration/configuration.json
echo ""
fi

# Download the schemes
mkdir -p /configuration/schemes
if [ -n "$SCHEMES" ]; then
  IFS=$' '
  for SCHEME in $SCHEMES; do
    echo "Downloading scheme $SCHEME"
    /usr/local/bin/irma scheme download /configuration/schemes "$SCHEME" || true
  done
fi

/usr/local/bin/irma server -c /configuration/configuration.json
