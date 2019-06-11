ARG CODE_VERSION=0.6.1
FROM kopano/kwebd:${CODE_VERSION}

ARG VCS_REF
ARG CODE_VERSION

ENV CODE_VERSION="${CODE_VERSION}"

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Web container" \
    org.label-schema.description="Reverse proxy for http(s) based components of kopano-docker" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

ENV KWEBD_USER root
ENV KWEBD_GROUP root
# hadolint ignore=DL3002
USER root
COPY wrapper.sh /usr/local/bin
COPY kweb.cfg /etc/kweb.cfg

