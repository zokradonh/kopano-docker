ARG CODE_VERSION=0.15.3
FROM kopano/kwmserverd:${CODE_VERSION}

ARG VCS_REF
ARG CODE_VERSION

ENV CODE_VERSION="${CODE_VERSION}"

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Kwmserver container" \
    org.label-schema.description="Container for running Kopano Kwmserver (WebRTC signalling server)" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

USER root

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY wrapper.sh /usr/local/bin

USER nobody
