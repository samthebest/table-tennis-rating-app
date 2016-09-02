#!/bin/bash
eval "$(docker-machine env default)"
docker exec -i -t `docker ps -a | grep ttra | head -1 | awk '{print $1}'` bash
