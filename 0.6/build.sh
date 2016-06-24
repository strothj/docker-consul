#!/bin/bash
set -e

VERSION=0.6

docker build -t strothj/vault:${VERSION} .
docker tag strothj/vault:${VERSION} strothj/vault