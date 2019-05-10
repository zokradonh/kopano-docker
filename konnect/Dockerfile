ARG CODE_VERSION=0.23.3
FROM kopano/konnectd:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

RUN apk add --no-cache \
	jq \
	moreutils \
	openssl \
	py-pip \
	&& pip install yq==2.7.2

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --chown=nobody:nogroup konnectd-identifier-registration.yaml konnectd-identifier-scopes.yaml /etc/kopano/
COPY wrapper.sh /usr/local/bin
