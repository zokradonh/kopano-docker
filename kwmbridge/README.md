# Kopano Kwmbridge image (SFU for Kopano Meet)

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_kwmbridge.svg)](https://microbadger.com/images/zokradonh/kopano_kwmbridge "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_kwmbridge.svg)](https://microbadger.com/images/zokradonh/kopano_kwmbridge "Microbadger version")

Image to run [Kopano Kwmbridge](https://github.com/kopano-dev/kwmbridge). Takes the [official image](https://cloud.docker.com/u/kopano/repository/docker/kopano/kwmserverd) and extends it for automatic configuration. Optional component of Kopano Meet/Kwmserver.

To work Kwmbridge needs a large range of forwarded ports and therefore running the container in host mode is probably the most useful approach. In case Meet is running behind NAT it could additionally be helpful to run Kwmbridge on a dedicated system, which would be directly reachable.
