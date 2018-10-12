#!/bin/bash


function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# query community server by h5ai API
filename=$(curl -s -S -L -d "action=get&items%5Bhref%5D=%2Fcommunity%2F$1%3A%2F&items%5Bwhat%5D=1" -H \
                "Accept: application/json" https://download.kopano.io/community/ | jq '.items[].href' | \
                grep Debian_9.0-a | sed 's#"##g' | sed "s#/community/$1:/##")

filename=$(urldecode $filename)

# download & extract packages
curl -s -S -L -o $filename https://download.kopano.io/community/$1:/${filename}

tar xf $filename

# save disk space
rm $filename

# prepare directory to be apt source
apt-ftparchive packages ${filename%.tar.gz} >> Packages

