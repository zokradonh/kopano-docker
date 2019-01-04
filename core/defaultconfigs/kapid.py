import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/kapid.cfg":
    {
        'log_level': "info",
	'listen': "0.0.0.0:8039",
	'plugin_pubs_secret_key': "/kopano/ssl/kapid-pubs-secret.key",
	'plugin_grapi_socket_path': "/var/run/kopano/grapi"

    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
