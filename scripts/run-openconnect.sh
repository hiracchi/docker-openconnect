#!/bin/bash

if [ -f /data/openconnect.conf ]; then
    source /data/openconnect.conf
fi

echo "USER: ${OPENCONNECT_USER}"
echo "HOST: ${OPENCONNECT_SERVER}"

echo -n "${OPENCONNECT_PASSWORD}" | sudo openconnect --passwd-on-stdin -u "${OPENCONNECT_USER}" "${OPENCONNECT_SERVER}"
