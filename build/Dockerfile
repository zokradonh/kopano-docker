FROM docker:18.09.6
ENV COMPOSE_VERSION "1.19.0"
ENV REG_VERSION "0.16.0"
RUN apk add --no-cache bash curl expect make nano jq py-pip
RUN pip install --no-cache-dir docker-compose==${COMPOSE_VERSION}
# the 0.16.0 release of reg has a bug that breaks loading tags from the docker hub.
# issue is fixed in master, but not in a release.
# rel https://github.com/genuinetools/reg/issues/186
RUN curl -fSL "https://github.com/genuinetools/reg/releases/download/v$REG_VERSION/reg-linux-amd64" -o "/usr/local/bin/reg" \
    && chmod a+x "/usr/local/bin/reg"
WORKDIR /kopano-docker
CMD ["bash"]
