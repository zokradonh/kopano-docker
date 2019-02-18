ARG CODE_VERSION=0.15.1
FROM kopano/kwmserverd:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

USER root

COPY wrapper.sh /usr/local/bin

# Run as nobody by default is always a good idea.
USER nobody
