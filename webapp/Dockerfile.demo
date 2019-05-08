ARG docker_repo=zokradonh
FROM ${docker_repo}/kopano_webapp

# hadolint ignore=SC2016
RUN sed -i '1s/^/<?php  $user="user".rand(1, 15); ?>\n/' /usr/share/kopano-webapp/server/includes/templates/login.php && \
    sed -i 's/id="password"/id="password" value="<?php echo $user; ?>"/' /usr/share/kopano-webapp/server/includes/templates/login.php
