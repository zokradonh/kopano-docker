#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/monitor.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'log_level': "4"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
