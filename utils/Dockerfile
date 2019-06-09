ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_core

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano utils container" \
    org.label-schema.description="Container that bundles various cli tools from Kopano Groupware Core" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker" \
    org.label-schema.version=$KOPANO_CORE_VERSION \
    org.label-schema.schema-version="1.0"

RUN apt-get update && apt-get install --no-install-recommends -y \
    vim nano man \
    kopano-backup \
    kopano-migration-imap \
    kopano-migration-pst \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash" ]
