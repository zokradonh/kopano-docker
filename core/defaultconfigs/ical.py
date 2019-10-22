import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/ical.cfg":
    {
        'ical_listen': "0.0.0.0:8080",
        'log_file': "-",
        'log_level': "3"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
