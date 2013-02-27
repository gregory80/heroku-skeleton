#!/bin/bash
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR
pushd ../..
source venv/bin/activate
# start foreman, for local dev
foreman start --procfile=./Procfile
#
exit 0