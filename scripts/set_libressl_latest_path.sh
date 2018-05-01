#!/bin/bash
# Description: Sets the position of the most recent version of libressl in the
# PATH environment variable

# set working directory to the one containing this script so it can find other
# scripts.
cd "$(dirname "$0")" || exit

OPENSSL_LATEST_PATH=$(find /usr/local/Cellar/libressl -name "bin" -maxdepth 2 -type d | sort -nr | head -n 1)

if [ -n "$OPENSSL_LATEST_PATH" ] ; then
    echo "Attempting to fix..."
    python ./set_path_precedence.py "$OPENSSL_LATEST_PATH" "/usr/bin"
else
    echo "Could not find Homebrew installation of LibreSSL."
fi
