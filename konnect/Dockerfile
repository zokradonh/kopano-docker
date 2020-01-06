ARG CODE_VERSION=0.28.0

FROM golang:1.13.5-alpine3.10 as builder-sponge

RUN apk add --no-cache git
RUN go get -d -v github.com/go-moreutils/sponge
RUN go install -v github.com/go-moreutils/sponge

FROM kopano/konnectd:${CODE_VERSION}

ARG VCS_REF
ARG CODE_VERSION

ENV CODE_VERSION="${CODE_VERSION}" \
    DEBUG="" \
    FQDN=localhost \
    KONNECT_BACKEND="kc" \
    ecparam=/etc/kopano/ecparam.pem \
    eckey=/etc/kopano/meet-kwmserver.pem \
    signing_private_key=/etc/kopano/konnectd-signing-private-key.pem \
    encryption_secret_key=/etc/kopano/konnectd-encryption-secret.key \
    identifier_registration_conf=/etc/kopano/konnectd-identifier-registration.yaml \
    identifier_scopes_conf=/etc/kopano/konnectd-identifier-scopes.yaml

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Konnect container" \
    org.label-schema.description="Container for running Kopano Konnect" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

# TODO use docker multistage for pip install yq https://pythonspeed.com/articles/multi-stage-docker-python/
RUN apk add --no-cache \
    jq \
    openssl \
    py-pip \
    && pip install yq==2.7.2

COPY --from=builder-sponge /go/bin/sponge /usr/local/bin

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --chown=nobody:nogroup konnectd-identifier-registration.yaml konnectd-identifier-scopes.yaml /etc/kopano/
COPY wrapper.sh /usr/local/bin

USER nobody

ENTRYPOINT ["wrapper.sh"]
