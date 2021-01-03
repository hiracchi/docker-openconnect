#!/bin/bash

echo -n "${OPENCONNECT_PASSWORD}" | openconnect --passwd-on-stdin -u "${OPENCONNECT_USER}" "${OPENCONNECT_SERVER}"
