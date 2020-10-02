ARG CODE_VERSION=0.12.4
FROM kopano/kwebd:${CODE_VERSION}

ARG CODE_VERSION

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Web container" \
    org.label-schema.description="Reverse proxy for http(s) based components of kopano-docker" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

ENV \
    AUTOCONFIGURE=true \
    CODE_VERSION="${CODE_VERSION}" \
    DEFAULTREDIRECT="/webapp" \
    KONNECTPATH=kopanoid \
    TLS_MODE=tls_auto
# FIXME Workaround to not break backwards compatibility,
# since an underscore is not a valid char in a hostname.
# This causes issues when using kweb in kubernetes.
# Related issue https://github.com/docker/compose/issues/229
ENV \
    KWEBD_DNS_GRAPI="kopano_grapi" \
    KWEBD_DNS_ICAL="kopano_ical" \
    KWEBD_DNS_ICAL="kopano_ical" \
    KWEBD_DNS_KAPI="kopano_kapi" \
    KWEBD_DNS_KAPPS="kopano_kapps" \
    KWEBD_DNS_KDAV="kopano_kdav" \
    KWEBD_DNS_KONNECT="kopano_konnect" \
    KWEBD_DNS_KWMSERVER="kopano_kwmserver" \
    KWEBD_DNS_MEET="kopano_meet" \
    KWEBD_DNS_PLAYGROUND="kopano_playground" \
    KWEBD_DNS_WEBAPP="kopano_webapp" \
    KWEBD_DNS_ZPUSH="kopano_zpush"

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY kweb.cfg tls_* /etc/
COPY wrapper.sh /usr/local/bin/

ENTRYPOINT ["wrapper.sh"]

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF
