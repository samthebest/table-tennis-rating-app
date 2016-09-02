#!/bin/bash

docker stop `docker ps -a | grep "ttra" | head -1 | awk '{print $1}'`
