#!/bin/bash

set -e

notebook_name=$1
port=$2

source ./docker/bin/utils.sh

test_notebook `cat ${notebook_name} | jq -r '.id'` ${port}