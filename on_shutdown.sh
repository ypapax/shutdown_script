#!/usr/bin/env bash
# https://cloud.google.com/compute/docs/shutdownscript
set -x
log=/var/log/shut_down.log
exec > >(tee -i $log)
exec 2>&1
docker stop $(docker ps -a -q)
docker_stop_result=$?
docker ps -a
docker info | head -4
date
hostname
#curl -X POST -d "$(date) running containers on $(hostname) docker ps -a: $(docker ps -a);  docker info: $( docker info | head -4)" http://trap_exit.requestcatcher.com/test
#curl -X POST -d "$(date) $(hostname) stop status code: $result" http://trap_exit.requestcatcher.com/test
curl -X POST -d "shutdown script logs $(cat $log)" http://trap_exit.requestcatcher.com/test
