#!/bin/bash

set -x
set -e

APP=$1

# go to source
cd $APP && ./$APP
