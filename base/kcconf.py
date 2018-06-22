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
            if key == "kccomment":
                for line in newvalue:
                    contents = re.sub(r"^\s*" + re.escape(line), r"#{}".format(line), contents, 0, re.MULTILINE)
            elif key == "kcuncomment":
                for line in newvalue:
                    contents = re.sub(r"^\s*#\s*" + re.escape(line) , line, contents, 0, re.MULTILINE)
            else:
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
            if prependingpath + filename not in configs:
                configs[prependingpath + filename] = dict()
            confkey = namematch.group(2).lower()
            configs[prependingpath + filename][confkey] = value
        commentmatch = re.match(r"^KCCOMMENT_([A-Z]+)_([A-Z0-9_]+)$", name)
        if commentmatch != None:
            filename = commentmatch.group(1).lower() + ".cfg"
            try: 
                configs[prependingpath + filename]["kccomment"].append(value)
            except IndexError:
                configs[prependingpath + filename]["kccomment"] = []
                configs[prependingpath + filename]["kccomment"].append(value)
        uncommentmatch = re.match(r"^KCUNCOMMENT_([A-Z]+)_([A-Z0-9_]+)$", name)
        if uncommentmatch != None:
            filename = uncommentmatch.group(1).lower() + ".cfg"
            try: 
                configs[prependingpath + filename]["kunccomment"].append(value)
            except IndexError:
                configs[prependingpath + filename]["kunccomment"] = []
                configs[prependingpath + filename]["kunccomment"].append(value)
    return configs
