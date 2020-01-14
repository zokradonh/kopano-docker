import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/search.cfg":
    {
        'log_file': "-",
        'log_level': "4",
        'index_path': "/kopano/data/search/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
