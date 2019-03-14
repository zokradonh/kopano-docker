FROM docker:18.09.1
ENV COMPOSE_VERSION "1.23.2"
RUN apk add --no-cache bash curl expect make nano jq py-pip
RUN pip install --no-cache-dir docker-compose==${COMPOSE_VERSION}
WORKDIR /kopano-docker
CMD ["bash"]
