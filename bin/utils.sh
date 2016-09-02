#!/bin/bash

set -ex

config_notebook=docker/template-notebooks/Configuration.json
demo_notebooks=`ls docker/demo-notebooks/ | awk '{print "docker/demo-notebooks/" $1}'`
template_notebooks=`ls docker/template-notebooks/ | grep -v Configuration | awk '{print "docker/template-notebooks/" $1}'`
test_notebooks=`ls docker/test-notebooks/ | awk '{print "docker/test-notebooks/" $1}'`

function create_notebook_dir {
    rm -r docker/notebooks || true

    for notebook in $*
    do
        id=`cat ${notebook} | jq -r '.id'`
        mkdir -p docker/notebooks/${id}
        cp ${notebook} docker/notebooks/${id}/note.json
    done
}

ip=`echo ${DOCKER_HOST} | cut -c 7- | cut -c -14`

# Only works for mac
export IP=`echo ${DOCKER_HOST} | cut -c 7- | cut -c -14`

# For linux
if [ "${IP}" = "" ]; then
    IP=localhost
fi


function setup_interpreter {
    max_loops=200
    loops=0
    port=$1

    test "${port}" != ""

    # TODO Use a TRAP in the custom-zeppelin that creates a fail file which we could check for
    echo "INFO: Starting zeppelin ..."
    echo "INFO: getting interpreter settings from: http://${IP}:${port}/api/interpreter"
    until curl -XGET http://${IP}:${port}/api/interpreter 1>/dev/null 2>/dev/null
    do
        sleep 10
        echo "INFO: ..."
        loops=`expr ${loops} + 1`
        if [ ${loops} = ${max_loops} ]; then
            echo "ERROR: Couldn't start zeppelin"
            exit 1
        fi
    done

    echo "INFO: Intitialising interpreters"

    interpreter_settings_ids=`curl -XGET http://${IP}:${port}/api/interpreter/setting | jq '.body[] | .id'`

    export ID_ARRAY="["`echo ${interpreter_settings_ids} | tr ' ' ',' `"]"
}

function job_success {
    notebook_id=$1
    port=$2

    test "${port}" != ""

    run_result=`curl -XGET http://${IP}:${port}/api/notebook/job/${notebook_id} 2>/dev/null`

    status=`echo "${run_result}" | jq -r '.status'`
    test "$status" = "OK"

    cell_statuses=`echo "${run_result}" | jq '.body[] | .status'`

    num_cells=`echo "${cell_statuses}" | wc -l`
    num_successes=`echo "${cell_statuses}" | grep FINISHED | wc -l`
    mkdir -p tmp
    test ${num_cells} = ${num_successes} && echo "${run_result}" > ./tmp/last-run-result.json
}

function job_fail {
    notebook_id=$1
    port=$2

    test "${port}" != ""

    run_result=`curl -XGET http://${IP}:${port}/api/notebook/job/${notebook_id} 2>/dev/null`

    function cell_has_error {
        cell_statuses=`echo "${run_result}" | jq '.body[] | .status'`

        echo "${cell_statuses}" | grep ERROR

        has_error=$?

        if [ "$has_error" = "0" ]; then
            echo "DEBUG: notebook msgs:"
            notebook_json=`curl -XGET http://${IP}:${port}/api/notebook/${notebook_id}`
            mkdir -p tmp
            echo ${notebook_json} > ./tmp/last-notebook-fail.json
            echo ${notebook_json} | jq -r '.body.paragraphs[] | .result.msg'
            return 0
        fi

        return 1
    }

    status=`echo "${run_result}" | jq -r '.status'`
    test "${status}" != "OK" || cell_has_error
}

function set_interpreters_for_notebook {
    notebook_id=$1
    port=$2

    test "${port}" != ""
    echo "INFO: Setting interpreters for notebook ${notebook_id}"
    curl -H 'Content-Type:application/json' -XPUT -d "${ID_ARRAY}" http://${IP}:${port}/api/notebook/interpreter/bind/${notebook_id}
}

function test_notebook {
    notebook_id=$1
    port=$2

    set_interpreters_for_notebook ${notebook_id} ${port}

    echo "INFO: Running notebook: $notebook_id"

    curl -XPOST http://${IP}:${port}/api/notebook/job/${notebook_id}

    echo "INFO: Waiting for notebook to finish"

    until job_success ${notebook_id} ${port} || job_fail ${notebook_id} ${port}
    do
        sleep 10
        echo "INFO: ..."
    done

    job_success ${notebook_id} ${port}
}

function setup_notebooks_at_startup {
    port=8080

    touch SETUP_STARTED

    # Wait for it to start for a bit
    sleep 10

    setup_interpreter ${port}

    sleep 2

    test_notebook `cat ${config_notebook} | jq -r '.id'` ${port}

    sleep 2

    for notebook in ${demo_notebooks} ${template_notebooks}
    do
        set_interpreters_for_notebook `cat ${notebook} | jq -r '.id'` ${port}
        sleep 2
    done

    # Bit of a dirty hack to address the issue that test_notebooks won't be on the server
    # long term solution to this ever growing bash code is to use rewrite it in Scala
    for notebook in ${test_notebooks}
    do
        set_interpreters_for_notebook `cat ${notebook} | jq -r '.id'` ${port} || true
        sleep 2
    done

    touch SETUP_COMPLETED
}

function wait_for_setup_to_complete {
    echo "INFO: Waiting for setup to complete"

    attempts=0

    until setup_complete
    do
        sleep 10
        echo "INFO: waiting for setup to complete ... $attempts"
        attempts=`expr ${attempts} + 1`
    done
}
