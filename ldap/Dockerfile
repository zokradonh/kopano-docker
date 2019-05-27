ARG CODE_VERSION=1.2.4
FROM osixia/openldap:${CODE_VERSION}
ARG CODE_VERSION
ENV CODE_VERSION="${CODE_VERSION}"

COPY bootstrap /container/service/slapd/assets/config/bootstrap
RUN rm /container/service/slapd/assets/config/bootstrap/schema/mmc/mail.schema
RUN touch /etc/ldap/slapd.conf
