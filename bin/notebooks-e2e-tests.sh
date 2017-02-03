#!/bin/bash

set -ex

export CUSTOM_ZEPPELIN_ARGS=$1

trap ./bin/stop.sh INT TERM EXIT

source ./bin/utils.sh

sbt "it:test-only ${project_name}.NotebookE2ETests"
