#!/bin/sh


if [ -f /kopano/ssl/ca.pem ]
  then exit 0
fi

/gencerts.sh