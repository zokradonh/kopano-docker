# Kopano Kwmserver image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_meet.svg)](https://microbadger.com/images/zokradonh/kopano_meet "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_meet.svg)](https://microbadger.com/images/zokradonh/kopano_meet "Microbadger version")

Image to run [Kopano Meet](https://github.com/Kopano-dev/meet).

## Configuration through environment variables

Any additional configuration should be done through environment variables and not done in the actual container. The images working with configuration files (e.g. `kopano_core`, `kopano_webapp`, `kopano_meet`) have a mechanism built in to translate env variables into configuration files. For services that can directly work with env variables (e.g. `kopano_konnect`, ´kopano_kwmserver´) these can be specified directly. Please check the individual `README.md` files for further instructions.

Examples of env variables:

```
KCCONF_KWEBD_TLS=no
^      ^     ^   ^
|      |     |   |
General prefix   |
       |     |   |
       Name of the relevant configuration file (kwebd.cfg in this case)
             |   |
             Name of the configuration option in the configuration file
                 |
                 Value of the configuration option

```