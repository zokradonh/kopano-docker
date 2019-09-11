ARG CODE_VERSION=0.17.2
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

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ENV DOCKERIZE_VERSION v0.11.0
RUN wget -O - https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-"$(uname -s)"-"$(uname -m)" | install /dev/stdin /bin/dockerize

COPY wrapper.sh /usr/local/bin

USER nobody
