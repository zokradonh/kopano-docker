#!/bin/sh

set -e

exec kwebd caddy -conf /etc/kweb.cfg -agree
