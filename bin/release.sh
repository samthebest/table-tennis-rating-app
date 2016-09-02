#!/bin/bash

set -ex

OPTIND=1

function show_help {
    echo "-b to skip building the jar (useful for debugging the Dockerfile)"
    echo "-B will build only and not run it-tests. This is used by build.sh in the root of the project"
    echo "-s will build and deploy a snapshot and will not tag and such and such, useful for developing"
    echo "-i will skip the integrations tests"
    echo "-p port used for it-tests"
    echo "-P port used by container upon release"
    echo "-l label used to label container (either prod or test, default: prod)"
    echo "-H to set the Host (default: ???)"
}

build_args=""

user=ttra-user
release_port=80
label=prod
host=???

while getopts "h?cbBsu:p:P:l:H:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  build_args="${build_args} -b"
        ;;
    B)  build_args="${build_args} -B"
        ;;
    s)  build_snapshot=true
        ;;
    u)  user=$OPTARG
        ;;
    p)  build_args="${build_args} -p $OPTARG"
        ;;
    P)  release_port=$OPTARG
        ;;
    l)  label=$OPTARG
        ;;
    H)  host=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ "${build_snapshot}" != "true" ]; then
    echo "INFO: Checking this is indeed master branch"

    git branch | grep "*" | grep master
fi

./bin/build.sh ${build_args}

echo "INFO: Build success"

next_version=SNAPSHOT

if [ "${build_snapshot}" != "true" ]; then
    last_version=`git tag | egrep "^[0-9]+$" | sort -n | tail -1`

    if [ "${last_version}" = "" ]; then
        last_version=0
    fi

    next_version=`expr ${last_version} + 1`
fi

echo "INFO: This version will be: ${next_version}"

if [ "${build_snapshot}" != "true" ]; then
    git tag ${next_version} && git push --tags

    echo "INFO: now our tags are:"

    git show-ref --tags -d
fi

docker_image=ttra.tar

artefact_name=ttra-${next_version}.tar

# TODO Save artefact

function deploy {
    echo "INFO: Deploying to $host"

    tmp_artefact_store=/home/${user}/tmp-artefact-store

    echo "INFO: scp-ing"
    scp ${docker_image} ${user}@${host}:${tmp_artefact_store}/${artefact_name}

    scp bin/run-server-mode.sh ${user}@${host}:/home/${user}/

    ssh ${user}@${host} "/home/${user}/run-in-uat.sh -v ${next_version} -u ${user} -l ${label} -p ${release_port}"
}

deploy
