FROM docker:18.09

ARG VCS_REF

ENV \
    DOCKERIZE_VERSION=v0.6.1 \
    SUPERCRONIC_VERSION=0.1.9

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano scheduler container" \
    org.label-schema.description="Helper container for running tasks within the Kopano stack" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$SUPERCRONIC_VERSION \
    org.label-schema.schema-version="1.0"

RUN apk --no-cache add bash

RUN wget https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 \
    -O /usr/local/bin/supercronic \
    && chmod +x /usr/local/bin/supercronic

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY start.sh /usr/local/bin/

CMD ["start.sh"]
