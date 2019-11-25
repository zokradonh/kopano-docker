#!/usr/bin/env bash

echo "Configuring OIDC for kopano-docker"

set -x

occ app:enable openidconnect

TODAY=$(date)
cat <<EOF >/mnt/data/config/konnectd.config.php
<?php
// Generated on $TODAY
\$CONFIG = [
	'loglevel' => 0,
	'debug' => true,
	'openid-connect' => [
		'provider-url' => 'https://$OWNCLOUD_DOMAIN',
		'client-id' => 'ownCloud',
		'client-secret' => 'ownCloud',
		'loginButtonName' => 'kopano',
		'autoRedirectOnLoginPage' => false,
		'redirect-url' => 'https://$OWNCLOUD_DOMAIN/owncloud/index.php/apps/openidconnect/redirect',
		'mode' => 'email',
		'search-attribute' => 'email',
		'use-token-introspection-endpoint' => false
	],
];
EOF

true
