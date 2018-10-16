import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/gateway.cfg":
    {
        'log_file': "-",
        'log_level': "4",
        'tmp_path': "/tmp/gateway/",
        'pop3_listen': "",
        'imap_listen': "",
        'imaps_listen': "*:993"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
