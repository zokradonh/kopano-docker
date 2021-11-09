# syntax = docker/dockerfile:1.3-labs
FROM debian:buster

# install basics
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        apt-utils \
        ca-certificates \
        curl \
        gpg \
        gpg-agent \
        jq \
        locales \
        moreutils \
        && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

ARG DOWNLOAD_COMMUNITY_PACKAGES=1
ARG KOPANO_CORE_REPOSITORY_URL="file:/kopano/repo/core"
ARG KOPANO_KAPPS_REPOSITORY_URL="file:/kopano/repo/kapps"
ARG KOPANO_MEET_REPOSITORY_URL="file:/kopano/repo/meet"
ARG KOPANO_WEBAPP_FILES_REPOSITORY_URL="file:/kopano/repo/files"
ARG KOPANO_WEBAPP_MDM_REPOSITORY_URL="file:/kopano/repo/mdm"
ARG KOPANO_WEBAPP_REPOSITORY_URL="file:/kopano/repo/webapp"
ARG KOPANO_WEBAPP_SMIME_REPOSITORY_URL="file:/kopano/repo/smime"
ARG KOPANO_ZPUSH_REPOSITORY_URL="https://download.kopano.io/zhub/z-push:/final/Debian_10/"
ARG KOPANO_REPOSITORY_FLAGS="trusted=yes"
ARG DOWNLOAD_BRANCH=""
ARG DOWNLOAD_CHANNEL="community"
ARG DOWNLOAD_DISTRIBUTION="Debian_10"

ARG DEBUG=""


COPY create-kopano-repo.sh /kopano/helper/
COPY Release.key /kopano/repo/

COPY <<-FILE /etc/apt/sources.list.d/kopano.list
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_CORE_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_KAPPS_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_MEET_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_SMIME_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_MDM_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_WEBAPP_FILES_REPOSITORY_URL} ./
    deb [${KOPANO_REPOSITORY_FLAGS}] ${KOPANO_ZPUSH_REPOSITORY_URL} /
FILE

WORKDIR /kopano/repo

SHELL [ "/bin/bash", "-c"]

RUN <<SCRIPT
    . /kopano/helper/create-kopano-repo.sh
    if [ ${DOWNLOAD_COMMUNITY_PACKAGES} -eq 1 ]; then
        dl_and_package_community "core" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "kapps" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "webapp" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "files" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "mdm" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "smime" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
        dl_and_package_community "meet" "$DOWNLOAD_DISTRIBUTION" "$DOWNLOAD_CHANNEL" "$DOWNLOAD_BRANCH"
    fi
SCRIPT