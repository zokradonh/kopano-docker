import os
import kcconf

# Component specific configurations
#kcconf.configkopano({
#    r"/etc/kopano/grapi.cfg":
#    {
#        'log_level': "info"
#    }
#})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
