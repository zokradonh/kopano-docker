<?php
$CONFIG = [
  'loglevel' => 0,
  'debug' => true,
  'openid-connect' => [
      'provider-url' => 'https://kopano.demo:2015',
      'client-id' => 'ownCloud',
      'client-secret' => 'ownCloud',
      'loginButtonName' => 'kopano',
      'autoRedirectOnLoginPage' => false,
      'redirect-url' => 'https://kopano.demo:2015/owncloud/index.php/apps/openidconnect/redirect',
      'mode' => 'email',
      'search-attribute' => 'email',
      'use-token-introspection-endpoint' => false
  ],
];
