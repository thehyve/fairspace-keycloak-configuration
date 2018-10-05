#!/bin/bash
#
# Reads a file with a URL on each line and outputs it as a json array
#

REDIRECT_URL_FILE=$1

# Read lines
while read url; do
  QUOTED_REDIRECT_URLS="$QUOTED_REDIRECT_URLS \"$url\","
done < $REDIRECT_URL_FILE

# Remove trailing comma and add []
echo "[" ${QUOTED_REDIRECT_URLS%,} "]"
