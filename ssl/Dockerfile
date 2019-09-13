FROM alpine:3.10

ARG VCS_REF

ENV CODE_VERSION=1.1.0 \
    STEP_VERSION=0.12.0 \
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

RUN wget https://github.com/smallstep/cli/releases/download/v"$STEP_VERSION"/step_"$STEP_VERSION"_linux_amd64.tar.gz \
    && tar --strip-components=2 -C /usr/local/bin -xzvf step_"$STEP_VERSION"_linux_amd64.tar.gz step_0.12.0/bin/step \
    && rm step_"$STEP_VERSION"_linux_amd64.tar.gz \
    && step version

RUN apk add --no-cache \
    openssl

COPY start.sh /start.sh

RUN chmod a+x /start.sh

WORKDIR /kopano/easypki

CMD ["/start.sh"]
