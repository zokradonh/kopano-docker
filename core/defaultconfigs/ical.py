#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/ical.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'ical_listen': "0.0.0.0:8080",
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
