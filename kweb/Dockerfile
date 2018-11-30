FROM kopano/kwebd:latest
RUN apk add --no-cache libcap
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/kwebd
COPY Caddyfile /etc/Caddyfile
