from alpine:3.11 as builder

RUN apk add --no-cache \
        git make
RUN mkdir -p /web/oidc-playground /web/kapi-playground
RUN git clone https://stash.kopano.io/scm/~seisenmann/oidc-playground.git
RUN mv oidc-playground/www/* /web/oidc-playground
RUN git clone https://stash.kopano.io/scm/kc/kapi.git
RUN mv kapi/examples/* /web/kapi-playground
WORKDIR /web/kapi-playground
RUN rm Makefile && ln -s oidc-client-example.html index.html

FROM halverneus/static-file-server:v1.5.2

ARG VCS_REF
ARG CODE_VERSION

ENV PORT 8888

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Playground" \
    org.label-schema.description="Container for running Kopano playground applications for Kapi and OIDC" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.schema-version="1.0"

COPY --from=builder /web /web
