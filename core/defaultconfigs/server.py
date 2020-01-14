import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/server.cfg":
    {
        'attachment_path': "/kopano/data/attachments/",
        'kcoidc_initialize_timeout': "360",
        'log_file': "-",
        'log_level': "3",
        'server_listen_tls': "0.0.0.0:237",
        'server_listen': "0.0.0.0:236",
        'softdelete_lifetime': "0",
        'sync_gab_realtime': "no",
        'user_plugin_config': "/tmp/kopano/ldap.cfg",
        'user_plugin': "ldap"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
