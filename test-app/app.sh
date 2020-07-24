#!/usr/bin/env bash
set -eo pipefail

# TODO: Request asset at runtime
echo "Q" | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif