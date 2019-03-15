ARG CODE_VERSION=0.19.1
FROM kopano/konnectd:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

RUN apk add --update \
	jq \
	moreutils \
	openssl
#\
#	py-pip \
#	&& pip install yq==2.7.2

#RUN apk add --no-cache \
#	git \
#	openssl \
#	py-pip && \
#	git clone https://github.com/Gallore/yaml_cli /tmp/yaml_cli && \
#	pip install /tmp/yaml_cli

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --from=mikefarah/yq:2.2.0 /usr/bin/yq /usr/local/bin/yq

COPY --chown=nobody:nogroup konnectd-identifier-registration.yaml konnectd-identifier-scopes.yaml /etc/kopano/
COPY wrapper.sh /usr/local/bin
