ARG BASE_VERSION=latest
FROM zokradonh/kopano_base:${BASE_VERSION}

LABEL maintainer=az@zok.xyz \
      version="1.0"

# install kopano
RUN apt-get update && apt-get install -y --no-install-recommends \
    kopano-gateway python3-mapi \
    && rm -rf /var/cache/apt /var/lib/apt/lists

ADD configure.py /kopano/configure.py
ADD start.sh /kopano/start.sh

RUN chmod a+x /kopano/start.sh

EXPOSE 993/tcp

CMD [ "/kopano/start.sh" ]