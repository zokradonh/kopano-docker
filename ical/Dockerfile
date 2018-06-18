ARG KOPANO_CORE_VERSION=latest
FROM zokradonh/kopano_base:${KOPANO_CORE_VERSION}

LABEL maintainer=az@zok.xyz \
      version="1.0"

ADD configure.py /kopano/configure.py
ADD start.sh /kopano/start.sh

RUN chmod a+x /kopano/start.sh

CMD [ "bash", "-c", "/kopano/start.sh && /usr/sbin/kopano-ical -F" ]