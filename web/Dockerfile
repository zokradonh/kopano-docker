ARG CODE_VERSION=0.6.1
FROM kopano/kwebd:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

ENV KWEBD_USER root
ENV KWEBD_GROUP root
# hadolint ignore=DL3002
USER root
COPY wrapper.sh /usr/local/bin
COPY kweb.cfg /etc/kweb.cfg

