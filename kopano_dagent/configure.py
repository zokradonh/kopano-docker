import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/dagent.cfg":
    {
        'log_file': "-",
        'log_level': "4",
        'tmp_path': "/tmp/dagent/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
