#!/usr/bin/env python3
import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/spamd.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'log_level': "3"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))