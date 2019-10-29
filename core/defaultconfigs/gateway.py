import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/gateway.cfg":
    {
        'imap_listen': "0.0.0.0:143",
        'log_file': "-",
        'log_level': "3",
        'tmp_path': "/tmp/gateway/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
