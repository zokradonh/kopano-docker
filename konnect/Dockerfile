ARG CODE_VERSION=0.23.5
FROM kopano/konnectd:${CODE_VERSION}

ARG VCS_REF
ARG CODE_VERSION

ENV CODE_VERSION="${CODE_VERSION}"

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Konnect container" \
    org.label-schema.description="Container for running Kopano Konnect" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

RUN apk add --no-cache \
	jq \
	moreutils \
	openssl \
	py-pip \
	&& pip install yq==2.7.2

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --chown=nobody:nogroup konnectd-identifier-registration.yaml konnectd-identifier-scopes.yaml /etc/kopano/
COPY wrapper.sh /usr/local/bin
