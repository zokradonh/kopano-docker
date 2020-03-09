#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/search.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'index_path': "/kopano/data/search/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
