FROM kopano/kwebd:0.4.2
RUN apk add --no-cache libcap && \
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/kwebd
COPY Caddyfile /etc/Caddyfile
