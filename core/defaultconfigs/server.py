import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/server.cfg":
    {
        'log_file': "-",
        'log_level': "3",
        'attachment_path': "/kopano/data/attachments/",
        'user_plugin': "ldap",
        'server_listen': "0.0.0.0:236",
        'server_listen_tls': "0.0.0.0:237",
        'sync_gab_realtime': "no",
        'softdelete_lifetime': "0",
        'kcoidc_initialize_timeout': "360"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
