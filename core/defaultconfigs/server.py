#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/server.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'server_listen': "0.0.0.0:236",
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
