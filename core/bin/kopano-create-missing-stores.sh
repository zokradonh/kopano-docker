#!/bin/bash

for kuser in $(kopano-storeadm -O | grep -A999999999 "Entities without stores:" | tail -n +4 | awk '{print $2}'); do
	kopano-storeadm -n $kuser -C
done
