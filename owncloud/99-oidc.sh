#!/usr/bin/env bash

echo "Configuring OIDC for kopano-docker"

set -x

occ app:enable openidconnect

true
