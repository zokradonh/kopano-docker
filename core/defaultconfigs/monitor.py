import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/monitor.cfg":
    {
        'log_file': "-",
        'log_level': "4"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
