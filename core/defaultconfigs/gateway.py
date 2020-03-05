#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/gateway.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'imap_listen': "0.0.0.0:143",
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
