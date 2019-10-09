# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please see https://github.com/zokradonh/kopano-docker/blob/master/README.md#when-building-my-own-containers-how-can-i-make-sure-my-build-works-as-expected for testing remakrs

To speed up testing rebuilds you can override the git hash that is passed as a build argument.

Example: `make vcs_ref=invalid build-web` or `make vcs_ref=invalid build-all`
