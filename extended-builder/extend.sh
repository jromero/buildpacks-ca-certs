#!/usr/bin/env bash

DIR=$(cd $(dirname $0) && pwd)

if [ $# -lt 2 ]; then
    echo "Usage:"
    echo
    echo "./extend.sh <builder-to-extend> <new-name>"
    exit 1
fi

BUILDER=${1}
EXTENDED_BUILDER=${2}

# lookup preconfigured builder user
USER=$(docker inspect "${BUILDER}" | jq -r '.[].Config.User')

# builder our extended builder
docker build \
  --build-arg BUILDER="${BUILDER}" \
  --build-arg USER="${USER}" \
  -t "${EXTENDED_BUILDER}" \
  "${DIR}"