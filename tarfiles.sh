#!/bin/bash

TARFILES_DIR="tarfiles"
TARFILES_URLS="tarfiles.urls"

function banner {
echo "================================================================"
echo "$1"
echo "================================================================"
}

for url in `cat ${TARFILES_URLS}`; do
	TGZ="`basename $url`"
	banner "Downloading $TGZ"
	wget -q -c $url -O ${TARFILES_DIR}/`basename $url`
done
