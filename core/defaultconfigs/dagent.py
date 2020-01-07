import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/dagent.cfg":
    {
        'lmtp_listen': "0.0.0.0:2003",
        'log_file': "-",
        'log_level': "4",
        'tmp_path': "/tmp/dagent/"
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
