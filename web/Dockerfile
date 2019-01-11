ARG CODE_VERSION=0.4.2
FROM kopano/kwebd:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

COPY wrapper.sh /usr/local/bin
COPY kweb.cfg /etc/kweb.cfg

