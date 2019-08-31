ARG CODE_VERSION=0.7.0
FROM kopano/kwebd:${CODE_VERSION}

ARG VCS_REF
ARG CODE_VERSION

ENV CODE_VERSION="${CODE_VERSION}"
ENV DEFAULTREDIRECT="/webapp"
# Workaround to not break backwards compatibility,
# since an underscore is not a valid char in a hostname.
# This causes issues when using kweb in kubernetes.
# Related issue https://github.com/docker/compose/issues/229
ENV KWEBD_DNS_KONNECT="kopano_konnect"
ENV KWEBD_DNS_MEET="kopano_meet"
ENV KWEBD_DNS_KAPI="kopano_kapi"
ENV KWEBD_DNS_PLAYGROUND="kopano_playground"
ENV KWEBD_DNS_KWMSERVER="kopano_kwmserver"
ENV KWEBD_DNS_WEBAPP="kopano_webapp"
ENV KWEBD_DNS_ZPUSH="kopano_zpush"
ENV KWEBD_DNS_ICAL="kopano_ical"
ENV KWEBD_DNS_KDAV="kopano_kdav"
ENV KWEBD_DNS_GRAPI="kopano_grapi"
ENV KWEBD_DNS_ICAL="kopano_ical"

COPY wrapper.sh /usr/local/bin
COPY kweb.cfg /etc/kweb.cfg

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Web container" \
    org.label-schema.description="Reverse proxy for http(s) based components of kopano-docker" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"
