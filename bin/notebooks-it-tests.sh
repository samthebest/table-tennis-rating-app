#!/bin/bash

set -ex

export CUSTOM_ZEPPELIN_ARGS=$1

sbt "it:test-only ttra.NotebookE2ETests"
