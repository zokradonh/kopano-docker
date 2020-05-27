FROM docker:19.03

ENV \
    DOCKERIZE_VERSION=v0.6.1 \
    GOSS_VERSION=v0.3.11 \
    SUPERCRONIC_VERSION=0.1.9

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano scheduler container" \
    org.label-schema.description="Helper container for running tasks within the Kopano stack" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$SUPERCRONIC_VERSION \
    org.label-schema.schema-version="1.0"

RUN apk --no-cache add bash curl ca-certificates

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN wget https://github.com/aelsabbahy/goss/releases/download/$GOSS_VERSION/goss-linux-amd64 -O /usr/local/bin/goss \
    && chmod +x /usr/local/bin/goss \
    && goss --version

RUN wget https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 \
    -O /usr/local/bin/supercronic \
    && chmod +x /usr/local/bin/supercronic

# Setup timezone
ENV TZ=UTC
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
RUN printf '%s\n' "$TZ" > /etc/timezone

COPY start.sh /usr/local/bin/
COPY goss.yaml /goss/

CMD ["start.sh"]

# TODO interval does not only define how often the healtcheck is run, but also how long to wait for the first check after startup
HEALTHCHECK --interval=60m --timeout=15s \
    CMD goss -g /goss/goss.yaml validate

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF