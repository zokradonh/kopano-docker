ARG BASE_VERSION=latest
FROM zokradonh/kopano_base:${BASE_VERSION}

LABEL maintainer=az@zok.xyz \
      version="1.0"

# install kopano
# dagent does not seem to be fully migrated to python3 so python2-mapi is neccessary
RUN apt-get update && apt-get install -y --no-install-recommends \
    kopano-dagent \
    python2-mapi \
    && rm -rf /var/cache/apt /var/lib/apt/lists


ADD configure.py /kopano/configure.py
ADD start.sh /kopano/start.sh

RUN chmod a+x /kopano/start.sh

EXPOSE 2003/tcp

CMD [ "/kopano/start.sh" ]