#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/dagent.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'lmtp_listen': "0.0.0.0:2003",
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
