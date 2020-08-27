ARG CODE_VERSION=1.2.0
FROM kopano/kwmserverd:${CODE_VERSION}

ARG CODE_VERSION
ENV \
    AUTOCONFIGURE=true \
    CODE_VERSION="${CODE_VERSION}"

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Kwmserver container" \
    org.label-schema.description="Container for running Kopano Kwmserver (WebRTC signalling server)" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

USER root
ENV DOCKERIZE_VERSION v0.11.6
RUN wget -O - https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-"$(uname -s)"-"$(uname -m)" | install /dev/stdin /bin/dockerize
USER nobody

COPY wrapper.sh /usr/local/bin

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF
