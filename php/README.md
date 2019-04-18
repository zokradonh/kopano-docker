# Kopano PHP image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_php.svg)](https://microbadger.com/images/zokradonh/kopano_php "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_php.svg)](https://microbadger.com/images/zokradonh/kopano_php "Microbadger version")

Common base image for php based Kopano containers.

## Configuration through environment variables

Any additional configuration should be done through environment variables and not done in the actual container. The images working with configuration files (e.g. `kopano_core`, `kopano_webapp`, `kopano_meet`) have a mechanism built in to translate env variables into configuration files. For services that can directly work with env variables (e.g. `kopano_konnect`, ´kopano_kwmserver´) these can be specified directly. Please check the individual `README.md` files for further instructions.

Examples of env variables:

```
KCCONF_WEBAPP_CLIENT_TIMEOUT=3600
^      ^      ^              ^
|      |      |              |
General prefix|              |
       |      |              |
       Special value to signal the change should go into config.php belonging to WebApp
              |              |
              Name of the configuration option in the configuration file
                             |
                             Value of the configuration option

KCCONF_WEBAPPPLUGIN_MDM_PLUGIN_MDM_USER_DEFAULT_ENABLE_MDM=true
^      ^            ^   ^                                  ^
|      |            |   |                                  |
General prefix      |   |                                  | 
       |            |   |                                  |
       Special value to signal the change should go into config-$identifier.php (located in /etc/kopano/webapp)
                    |   |                                  |
                    Identifier for the configuration file (config-$identifier.php)
                        |                                  |
                        Name of the configuration option in the configuration file
                                                           |
                                                           Value of the configuration option
```