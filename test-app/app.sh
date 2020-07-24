#!/usr/bin/env bash
set -eo pipefail

echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif