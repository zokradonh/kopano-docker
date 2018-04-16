FROM debian:stretch

LABEL maintainer=az@zok.xyz \
      version="1.1"

RUN mkdir -p /kopano/repo && mkdir -p /kopano/data
WORKDIR /kopano/repo

ENV DEBIAN_FRONTEND noninteractive

ARG KOPANO_REPOSITORY=http://localhost:8081/kopanoarchive/

# # get kopano packages
# RUN curl -L `lynx -listonly -nonumbers -dump ${KOPANO_REPOSITORY}core:/ | grep ${DISTRIBUTION}-${ARCH}.tar.gz | grep --regexp=${CORE_VERSION_FILTER}` | tar xzf - --strip-components 1
# RUN curl -L `lynx -listonly -nonumbers -dump ${KOPANO_REPOSITORY}webapp:/ | grep ${DISTRIBUTION}-all.tar.gz | grep --regexp=${WEBAPP_VERSION_FILTER}` | tar xzf - --strip-components 1

# # create and add repositories
# RUN apt-ftparchive packages . | gzip -9c > Packages.gz && echo "deb [trusted=yes] file:/kopano/repo ./" > /etc/apt/sources.list.d/kopano.list; \
#     echo "deb http://repo.z-hub.io/z-push:/final/${DISTRIBUTION}/ /" > /etc/apt/sources.list.d/zpush.list; \
#     apt-key add /kopano/repo/z-push-GPG.key

# trigger rebuild from here on new version - dont use cache my dear docker
ARG CORE_VERSION

# install base components
RUN echo ${CORE_VERSION} > /kopano/buildversion && \
    echo "deb [trusted=yes] ${KOPANO_REPOSITORY} ./" > /etc/apt/sources.list.d/kopano.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gpg \
    kopano-common \
    python3-kopano \
    ca-certificates \
    moreutils \
    && rm -rf /var/cache/apt /var/lib/apt/lists

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    sed -e 's,^KOPANO_LOCALE="C",KOPANO_LOCALE="de_DE.UTF-8",' -i /etc/default/kopano && \
    sed -e 's,^KOPANO_USERSCRIPT_LOCALE="C",KOPANO_USERSCRIPT_LOCALE="de_DE.UTF-8",' -i /etc/default/kopano && \
    curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod a+x /usr/local/bin/dumb-init

ENV LANG en_US.UTF-8 

ADD kcconf.py /kopano/kcconf.py

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]