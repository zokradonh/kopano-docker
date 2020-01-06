FROM alpine:3.11

ARG VCS_REF

ENV CODE_VERSION=1.2.0 \
    PKI_ROOT=/kopano/easypki \
    PKI_ORGANIZATION="Internal Kopano System" \
    PKI_COUNTRY=DE

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano SSL container" \
    org.label-schema.description="Helper Container for carrying out ssl related activities for the Kopano stack." \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$CODE_VERSION \
    org.label-schema.schema-version="1.0"

RUN mkdir -p /kopano/easypki /kopano/ssl /kopano/ssl/clients
WORKDIR /kopano/easypki

RUN apk add --no-cache \
    easypki \
    openssl

COPY start.sh /start.sh

RUN chmod a+x /start.sh

CMD ["/start.sh"]
