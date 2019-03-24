FROM docker:18.09.1

ENV SUPERCRONIC_VERSION 0.1.8
RUN wget https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 \
    -O /usr/local/bin/supercronic \
    && chmod +x /usr/local/bin/supercronic

CMD ["supercronic","/etc/crontab"]
