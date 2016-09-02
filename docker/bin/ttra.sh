#!/bin/bash

set -ex

OPTIND=1

memory=23

while getopts "g:" opt; do
    case "$opt" in
    g)  memory=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "#!/bin/bash" > /usr/zeppelin/conf/zeppelin-env.sh
echo "export ZEPPELIN_MEM=\"-Xmx512m\"" >> /usr/zeppelin/conf/zeppelin-env.sh
echo "export ZEPPELIN_INTP_MEM=\"-Xmx${memory}g\"" >> /usr/zeppelin/conf/zeppelin-env.sh

# We are currently using the out-of-box mode for zeppelin meaning it acts as a spark master by pulling in spark classes,
# rather than submitting itself as
# would be usual with spark-submit.  This means we set the memory for Spark in the following way. (c.f. spark/src/main/java/org/apache/zeppelin/spark/SparkInterpreter.java)
# Zeppelin recommends setting SPARK_HOME and not doing it this way.


#echo "export ZEPPELIN_JAVA_OPTS=\"-Dspark.executor.memory=${memory}g -Dspark.driver.memory=${memory}g -Dspark.cores.max=16 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Xdebug -Xrunjdwp:transport=dt_socket,address=62911,server=y,suspend=n  -Dcom.sun.management.jmxremote.port=1898  \"" >> /usr/zeppelin/conf/zeppelin-env.sh
echo "export ZEPPELIN_JAVA_OPTS=\"-Dspark.executor.memory=${memory}g -Dspark.driver.memory=${memory}g -Dspark.cores.max=16  \"" >> /usr/zeppelin/conf/zeppelin-env.sh


echo "export SPARK_SUBMIT_OPTIONS=\"--driver-memory ${memory}G --executor-memory ${memory}G --driver-cores 2 --executor-cores 2\"" >> /usr/zeppelin/conf/zeppelin-env.sh

log_day=`date +%d`

#echo "export SPARK_SUBMIT_JVM_OPTIONS=\"-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/zeppelin/host-volume/ -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:/usr/zeppelin/host-volume/gc.log.${log_day}  -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Xdebug -Xrunjdwp:transport=dt_socket,address=62911,server=y,suspend=n  -Dcom.sun.management.jmxremote.port=1898   \""  >> /usr/zeppelin/conf/zeppelin-env.sh
echo "export SPARK_SUBMIT_JVM_OPTIONS=\"-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/zeppelin/host-volume/ -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:/usr/zeppelin/host-volume/gc.log.${log_day} \""  >> /usr/zeppelin/conf/zeppelin-env.sh

# Bit of a hack cos docker volumes suck (should use external storage to backup notebooks)

# Could package the notebooks as part of the tar, but have them copied into the directory for mapping to the image
# just before we start the image.

official_notebooks=`ls /usr/zeppelin/notebook/`

function is_official {
    result=false
    for official_notebook in ${official_notebooks}
    do
        test ${official_notebook} = $1 && result=true && break
    done
    test ${result} = true
}

cp -r /usr/zeppelin/host-volume/* /usr/zeppelin/notebook/ || true

function backup_scratch_notebooks {
    for notebook in `ls /usr/zeppelin/notebook/`
    do
        is_official ${notebook} || cp -r /usr/zeppelin/notebook/${notebook} /usr/zeppelin/host-volume/
    done
}

function backup_loop {
    while [ 1 = 1 ]
    do
        backup_scratch_notebooks
        sleep 30
    done
}

set +x

#
# START AWESOME FILE SERVER
#

echo "INFO: Starting awesome file server"

/usr/zeppelin/bin/file-server.sh &

#
# START BACKUP LOOP
#

backup_loop &

#
# SETUP NOTEBOOKS
#

source bin/utils.sh

set +x

export IP=localhost

setup_notebooks_at_startup &

#
# RUN ZEPPELIN
#

./bin/zeppelin.sh
