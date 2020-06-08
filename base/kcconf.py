"""This module provides functions for easy editing of kopano config files
via environment variables"""

import re
import os
import os.path
import sys

def configkopano(configs):
    """ Changes configuration files according to configs typically returned from parseenvironmentvariables(..)"""
    for filename, config in configs.items():
        if not os.path.exists(filename):
            continue
        # read configuration file
        with open(filename) as f:
            contents = f.read()
        f.close()

        for key, newvalue in config.items():
            if key == "kccomment":
                # comment lines
                for line in newvalue:
                    contents = re.sub(r"^\s*" + re.escape(line), r"#{}".format(line), contents, 0, re.MULTILINE)
            elif key == "kcuncomment":
                # uncomment lines
                for line in newvalue:
                    contents = re.sub(r"^\s*#\s*" + re.escape(line) , line, contents, 0, re.MULTILINE)
            else:
                # find config line
                if re.search(r"^\s*#?\s*{}\s*=.*".format(key), contents, re.MULTILINE) == None:
                    # add configuration as new line
                    contents += "\n{} = {}".format(key, newvalue)
                else:
                    # change existing line
                    contents = re.sub(r"^\s*#?\s*{}\s*=.*".format(key), r"{} = {}".format(key, newvalue), contents, 0, re.MULTILINE)

        # save new configuration
        try:
            with open(filename, "w") as f:
                f.write(contents)
            f.close()
        except (OSError, PermissionError):
            print("Can't open {}, ignoring file changes".format(filename))


def parseenvironmentvariables(prependingpath):
    """ Parse all environment variables starting with KCCONF_, KCCOMMENT_ and KCUNCOMMENT_ and
    return as multi dimensional dict """
    configs = dict()

    for name, value in os.environ.items():
        # parse change/add configuration commands
        namematch = re.match(r"^KCCONF_([A-Z]+)_([A-Z0-9_]+)$", name)
        if namematch != None:
            filename = namematch.group(1).lower() + ".cfg"
            if prependingpath + filename not in configs:
                configs[prependingpath + filename] = dict()
            confkey = namematch.group(2).lower()
            configs[prependingpath + filename][confkey] = value
        # parse comment configuration commands
        commentmatch = re.match(r"^KCCOMMENT_([A-Z]+)_([A-Z0-9_]+)$", name)
        if commentmatch != None:
            filename = commentmatch.group(1).lower() + ".cfg"
            if prependingpath + filename not in configs:
                configs[prependingpath + filename] = dict()
            try:
                configs[prependingpath + filename]["kccomment"].append(value)
            except KeyError:
                configs[prependingpath + filename]["kccomment"] = []
                configs[prependingpath + filename]["kccomment"].append(value)
        # parse uncomment configuration commands
        uncommentmatch = re.match(r"^KCUNCOMMENT_([A-Z]+)_([A-Z0-9_]+)$", name)
        if uncommentmatch != None:
            filename = uncommentmatch.group(1).lower() + ".cfg"
            if prependingpath + filename not in configs:
                configs[prependingpath + filename] = dict()
            try:
                configs[prependingpath + filename]["kcuncomment"].append(value)
            except KeyError:
                configs[prependingpath + filename]["kcuncomment"] = []
                configs[prependingpath + filename]["kcuncomment"].append(value)
    return configs
