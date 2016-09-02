#!/bin/bash

# MANUAL TESTING:

# Checked this results in the zeppelin failing to start
# export ZEPPELIN_MEM="-Xmx512k"

# Checked this eliminates warning about PermGen removal
# export ZEPPELIN_MEM="-Xmx1024m"

# Checked this indeed causes connection refused when starting interpreters
# export ZEPPELIN_INTP_MEM="-Xmx512k"

export ZEPPELIN_MEM="-Xmx3000m"
export ZEPPELIN_INTP_MEM="-Xmx3000m"
#export SPARK_HOME=$SPARK_HOME
export SPARK_SUBMIT_OPTIONS="--driver-memory 3G --executor-memory 3G --cores 2"