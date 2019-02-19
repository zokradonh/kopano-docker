import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/kweb.cfg":
    {
        'tls': "no"

    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
