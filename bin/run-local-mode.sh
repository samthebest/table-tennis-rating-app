#!/bin/bash


set -ex

OPTIND=1

function show_help {
    echo "-c to skip updating the zeppelin repo (useful since it doesn't change often)"
    echo "-b to skip building the jar (useful for debugging the Dockerfile)"
    echo "-B will build only and not start zeppelin. This is used by build.sh in the root of the project"
    echo "-p port"
    echo "-t will skip tests as part of jar build (we should just make the tests faster)"
    echo "-m copy local maven and npn repos to docker container during build"
}

port=8080

while getopts "h?cbmBdtp:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  skip_zep_update=true
        ;;
    b)  skip_build=true
        ;;
    B)  build_only=true
        ;;
    p)  port=$OPTARG
        ;;
    t)  skip_test=true
        ;;
    m)  local_m2=true
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

mkdir -p host-volume

if [ "${skip_build}" != "true" ]; then
    if [ "${skip_test}" = "true" ]; then
        sbt 'set test in assembly := {}' clean assembly
    else
        ./bin/data-it-tests.sh
        sbt assembly
    fi
    cp target/scala-2.10/ttra-assembly-*.jar ./docker/ttra-assembly.jar
fi

if [ "${skip_zep_update}" != "true" ]; then
    echo "INFO: Updating custom-zeppelin"
    test -d docker/zeppelin || git clone https://github.com/apache/zeppelin.git docker/zeppelin

    branch=master
    commit=5f1208bdbace9a56ae2744193880a2be9ce118df

    git --git-dir=docker/zeppelin/.git --work-tree=docker/zeppelin fetch origin
    git --git-dir=docker/zeppelin/.git --work-tree=docker/zeppelin checkout ${branch}
    git --git-dir=docker/zeppelin/.git --work-tree=docker/zeppelin checkout ${commit}

    function update_without_git {
        rm -r docker/zeppelin-without-git || true
        cp -r docker/zeppelin docker/zeppelin-without-git
        rm -rf docker/zeppelin-without-git/.git
    }

    diff --exclude=".git" -r docker/zeppelin docker/zeppelin-without-git 1>/dev/null || update_without_git
fi

pwd=`pwd`

mkdir -p ${pwd}/host-volume

source ./docker/bin/utils.sh

create_notebook_dir ${config_notebook} ${demo_notebooks} ${template_notebooks} ${test_notebooks}

rm -r ./docker/maven_repo || true
rm -r ./docker/npm_repo || true
if [ "${local_m2}" == "true" ]; then
    cp -r ~/.m2/repository docker/maven_repo
    cp -r ~/.npm docker/npm_repo
else
    pwd
    mkdir -p docker/maven_repo
    mkdir -p docker/npm_repo
    ls -l
fi

docker build -t ttra docker

rm -r docker/maven_repo || true
rm -r docker/npm_repo || true

if [ "${build_only}" != "true" ]; then
    docker run -m 2500m -v ${pwd}/host-volume:/usr/zeppelin/host-volume -p ${port}:8080 \
      -p 62911:62911 -p 1898:1898 -p 4040:4040 -i ttra bin/zeppelin.sh -g2
fi
