#!/bin/sh

set -x
set -e

APP=$1

echo "Running $APP"

# go to source
cd $APP && ./$APP &
cd ..

# start the platform
echo "Running platform"
./platform
