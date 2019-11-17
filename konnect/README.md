# Kopano Konnect image

[![](https://images.microbadger.com/badges/image/zokradonh/kopano_konnect.svg)](https://microbadger.com/images/zokradonh/kopano_konnect "Microbadger size/labels") [![](https://images.microbadger.com/badges/version/zokradonh/kopano_konnect.svg)](https://microbadger.com/images/zokradonh/kopano_konnect "Microbadger version")

Image to run [Kopano Konnect](https://github.com/kopano-dev/konnect). Takes the [official image](https://cloud.docker.com/u/kopano/repository/docker/kopano/konnectd) and extends it for automatic configuration.

Currently the container does not support dynamically adding additional clients to the konnectd identifier registration. To add additional values modify the file manually and mount it to `/etc/kopano/konnectd-identifier-registration.yaml` (the container uses this file as a template when adding the required values for Kopano Meet).
