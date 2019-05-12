FROM docker:18.09.1
ENV COMPOSE_VERSION "1.23.2"
RUN apk add --no-cache bash curl expect make nano jq py-pip
RUN pip install --no-cache-dir docker-compose==${COMPOSE_VERSION}
RUN curl -fSL "https://github.com/genuinetools/reg/releases/download/v0.16.0/reg-linux-amd64" -o "/usr/local/bin/reg" \
    && chmod a+x "/usr/local/bin/reg"
WORKDIR /kopano-docker
CMD ["bash"]
