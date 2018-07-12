#!/usr/bin/env bash
set -ex

cleanup(){
	echo cleanup is called
	curl -X POST -d "cleanup is called on $(hostname) $(date)" http://trap_exit.requestcatcher.com/test
}

trap cleanup EXIT
curl -X POST -d "container is started on $(hostname) $(date)" http://trap_exit.requestcatcher.com/test
sleep 10000