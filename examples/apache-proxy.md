# Using Apache as the front facing reverse proxy

Example provided by [ronnybremer](https://github.com/ronnybremer) in [Add reverse proxy example for Apache](https://github.com/zokradonh/kopano-docker/issues/372).

To be able to use a different proxy, than the bundled kweb the env variable `FQDNCLEANED` needs to be set to an invalid value (to not route traffic through it, but the external proxy). Additionally `EMAIL` needs to be set to `off`.

```bash
<VirtualHost aaa.bbb.ccc.ddd:443 [aaaa:bbbb:cccc:dddd:eeee:ffff::yy]:443>
ServerName public.domain.com:443
ServerAdmin your_friendly_admin@domain.com
UseCanonicalName On

ErrorLog logs/meet_ssl_error_log
CustomLog logs/meet_ssl_access_log combined
LogLevel warn

SSLEngine on
SSLCompression off
SSLProxyEngine off

SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA
# for higher security
# SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLHonorCipherOrder on
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt

Header unset X-Frame-Options
Header unset Content-Security-Policy

RewriteEngine On
# Meet and PWAs only work on https
RewriteCond %{HTTPS} off
RewriteCond %{REQUEST_URI} ^/meet$ [OR]
RewriteCond %{REQUEST_URI} ^/meet/
RewriteRule ^(.*)$ https://public.domain.com/meet/ [R,L]
# We need to access Meet through the proper domain
RewriteCond %{REQUEST_URI} ^/meet$ [OR]
RewriteCond %{REQUEST_URI} ^/meet/
RewriteCond %{HTTP_HOST} !^public.domain.com$ [NC]
RewriteRule ^(.*)$ https://public.domain.com/meet/ [R,L]
# Upgrade Websocket connections
RewriteCond %{HTTP:Connection} Upgrade [NC]
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteRule /api/kwm/v2/(.*) ws://internal.domain.com:2015/api/kwm/v2/$1 [P,L]

<Directory />
    Order deny,allow
    Deny from all
</Directory>

<Location />
    ProxyPass        http://internal.domain.com:2015/
    ProxyPassReverse http://internal.domain.com:2015/
    ProxyPreserveHost On
</Location>

</VirtualHost>
```
