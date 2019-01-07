import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/kapid.cfg":
    {
        'log_level': "info",
        'listen': "0.0.0.0:8039",
        'DEFAULT_PLUGIN_PUBS_SECRET_KEY_FILE': "/kopano/ssl/kapid-pubs-secret.key",
        'plugin_kvs_db_datasource': "/kopano/data/kapi-kvs/kvs.db",
        'plugin_kvs_db_migrations': "/kopano/data/kapi-kvs/db/migrations",
        'plugin_grapi_socket_path': "/var/run/kopano/grapi"

    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
