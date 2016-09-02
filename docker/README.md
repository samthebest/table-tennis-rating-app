## Intro

This README currently assumes you use a mac. If you are familiar with Docker and linux then you should easily be able to
adjust.

## Install Docker

Don't use brew, docker sucks, have to download from here https://www.docker.com/products/docker-toolbox then follow the
 setup wizard. Then run:

```
docker-machine create --virtualbox-disk-size 50000 --virtualbox-memory 2500 \
--virtualbox-cpu-count 2 \
--driver virtualbox default && eval "$(docker-machine env default)"
```

## Docker Issues

Docker has billions of issues, most weird behaviour can be fixed with:

```
docker-machine restart default && eval "$(docker-machine env default)"
```

## Zeppelin

After installing docker. To start (regular) zeppelin run `./start-native-zeppelin.sh`.  The URL will be:

```
eval "$(docker-machine env default)"
echo $DOCKER_HOST | cut -c 7- | tr ':' ' ' | awk '{print $1 ":8080"}'
```

To run, run `./run-local-mode.sh`, this will likely be much slower first run as it will need to build the
image.  Not it has some command line options to skip certain steps, use `-h` to see the help.

This zeppelin docker file is based on https://github.com/dylanmei/docker-zeppelin.

## Disk space issues with docker

Try `docker-machine rm default` then rerun the docker-machine create command above. This will be very slow!

## To get inside (ssh) the running docker image

Just run `ssh.sh`
