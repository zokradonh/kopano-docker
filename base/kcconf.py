"""This module provides functions for easy editing of kopano config files \
via environment variables"""

import re
import os
import os.path

def configkopano(configs):
    for filename, config in configs.items():
        if not os.path.exists(filename):
            return
        with open(filename) as f:
            contents = f.read()
        f.close()

        for key, newvalue in config.items():
            contents = re.sub(r"^\s*#?\s*{}\s*=.*".format(key), r"{} = {}".format(key, newvalue), contents, 0, re.MULTILINE)

        with open(filename, "w") as f:
            f.write(contents)
        f.close()

def parseenvironmentvariables(prependingpath):
    configs = dict()
    for name, value in os.environ.items():
        namematch = re.match(r"^KCCONF_([A-Z]+)_([A-Z0-9_]+)$", name)
        if namematch != None:
            filename = namematch.group(1).lower() + ".cfg"
            if not configs.has_key(prependingpath + filename):
                configs[prependingpath + filename] = dict()
            confkey = namematch.group(2).lower()
            configs[prependingpath + filename][confkey] = value
    return configs
