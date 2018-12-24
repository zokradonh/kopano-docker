ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_core

RUN apt-get update && apt-get install --no-install-recommends -y \
    kopano-backup \
    kopano-migration-imap \
    kopano-migration-pst

CMD [ "/bin/bash" ]
