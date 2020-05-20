#!/usr/bin/env python3
import kcconf

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
