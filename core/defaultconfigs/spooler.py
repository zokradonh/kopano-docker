import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/spooler.cfg":
    {
        'log_file': "-",
        'log_level': "4",
        'tmp_path': "/tmp/spooler/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
