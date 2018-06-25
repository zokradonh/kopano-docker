import os
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/etc/kopano/server.cfg":
    {
        'log_file': "-",
        'log_level': "3",
        'attachment_path': "/kopano/data/attachments/",
        'user_plugin': "ldap",
        'server_listen': "",
        'server_listen_tls': "*:237"
    },
    r"/etc/kopano/ldap.cfg":
    {
        'kccomment': ["!include /usr/share/kopano/ldap.openldap.cfg"],
        'kcuncomment': ["!include /usr/share/kopano/ldap.active-directory.cfg"]
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/etc/kopano/"))
