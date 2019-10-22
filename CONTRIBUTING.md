# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## General architecture of containers

To get an impression how the containers interact/relate with each other have a look at the [architecture](ARCHITECTURE.md) description.

## Testing

This project includes a few automated tests that can be run to ensure that containers start up and are operational. Required tools for testing can be installed by executing `bash .ci/setup-tools.sh`.

The startup test can be executed by calling `make test-startup`. It spins up all containers and checks if they listen on their expected interfaces afterwards as well as execute some commands that should succeed on a successful deployment.

A more detailed test can be executed by calling `make test-goss`. This uses [Goss](https://github.com/aelsabbahy/goss) and its helper [dcgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dcgoss) to validate the container configuration at runtime. These tests have not been implemented for all containers yet, but as an upside the same validation is used as part of the container health check. Contributions are welcome!

Testing the startup scripts of the containers is still a work in progress. When running `make test-commander` [Commander](https://github.com/SimonBaeumer/commander) will be used to test output of the `version.sh` script and some of the container startup scripts.

## Tricks

To speed up testing rebuilds you can override the git hash that is passed as a build argument.

Example: `make vcs_ref=invalid build-web` or `make vcs_ref=invalid build-all`
