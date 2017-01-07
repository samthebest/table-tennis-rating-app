#!/bin/bash

set -ex

export CUSTOM_ZEPPELIN_ARGS=$1

trap ./bin/stop.sh INT TERM EXIT

sbt "it:test-only ttra.NotebookE2ETests"
