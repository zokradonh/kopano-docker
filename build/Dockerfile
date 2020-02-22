FROM docker:18.09
ENV \
    COMMANDER_VERSION=1.2.1 \
    COMPOSE_VERSION=1.19.0 \
    GOSS_VERSION=0.3.7 \
    HADOLINT_VERSION=1.17.1 \
    REG_VERSION=0.16.1 \
    TRIVY_VERSION=0.1.1

LABEL maintainer=az@zok.xyz \
    org.label-schema.name="Kopano Container Builder" \
    org.label-schema.description="Helper Container to help building and testing containers" \
    org.label-schema.url="https://kopano.io" \
    org.label-schema.vcs-url="https://github.com/zokradonh/kopano-docker/build/" \
    org.label-schema.version=1.0.0 \
    org.label-schema.schema-version="1.0"

RUN apk add --no-cache bash curl coreutils git grep expect make nano npm jq py-pip && \
    apk add --no-cache shellcheck --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN curl -fSL "https://github.com/genuinetools/reg/releases/download/v$REG_VERSION/reg-linux-amd64" -o "/usr/local/bin/reg" && \
    curl -fSL "https://github.com/hadolint/hadolint/releases/download/v$HADOLINT_VERSION/hadolint-$(uname -s)-$(uname -m)" -o /usr/local/bin/hadolint && \
    curl -fSL "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    curl -fSL "https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64" -o /usr/local/bin/goss && \
    curl -L "https://raw.githubusercontent.com/fbartels/goss/dcgoss-v2/extras/dcgoss/dcgoss -o /usr/local/bin/dcgoss" && \
    curl -fSL "https://github.com/SimonBaeumer/commander/releases/download/v$COMMANDER_VERSION/commander-linux-amd64" -o /usr/local/bin/commander && \
    curl -fSL "https://raw.githubusercontent.com/fbartels/dccommander/master/dccommander" -o /usr/local/bin/dccommander && \
    pip install --no-cache-dir yamllint==1.19.0 && \
    npm config set unsafe-perm true && \
    npm install -g eclint@2.8.1 && \
    chmod a+x /usr/local/bin/*

WORKDIR /kopano-docker
CMD ["bash"]
