ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_core

RUN apt-get update && apt-get install --no-install-recommends -y \
    vim nano man \
    kopano-backup \
    kopano-migration-imap \
    kopano-migration-pst \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash" ]
