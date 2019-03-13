FROM alpine:latest

LABEL maintainer=az@zok.xyz \
      version="1.0"

RUN mkdir -p /kopano/easypki /kopano/ssl /kopano/ssl/clients
WORKDIR /kopano/easypki

ENV PKI_ROOT /kopano/easypki
ENV PKI_ORGANIZATION Internal Kopano System
ENV PKI_COUNTRY DE

RUN apk add --no-cache \
    easypki \
    openssl

COPY start.sh /start.sh

RUN chmod a+x /start.sh

CMD ["/start.sh"]
