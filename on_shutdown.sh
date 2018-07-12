#!/usr/bin/env bash
# https://cloud.google.com/compute/docs/shutdownscript
curl -X POST -d "$(date) running containers on $(hostname): $(docker ps)" http://trap_exit.requestcatcher.com/test
docker stop $(docker ps -a -q)
result=$?
curl -X POST -d "$(date) $(hostname) stop status code: $result" http://trap_exit.requestcatcher.com/test
