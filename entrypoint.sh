#!/bin/bash

rippledconfig=`/bin/cat /etc/opt/ripple/rippled.cfg 2>/dev/null | wc -l`
validatorstxt=`/bin/cat /etc/opt/ripple/validators.txt 2>/dev/null | wc -l`

if [[ "$rippledconfig" -le "0" ]]; then
    echo "Error: Rippled configuration is missing. A valid rippled.cfg must be provided in /etc/opt/ripple/"
    exit 1
fi

if [[ "$validatorstxt" -le "0" ]]; then
    echo "Error: Validator configuration is missing. A valid validators.txt must be provided in /etc/opt/ripple/"
    exit 1
fi

exec /opt/build/rippled $ENV_ARGS