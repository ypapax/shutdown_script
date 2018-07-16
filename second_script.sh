#!/usr/bin/env bash
set -ex
echo second_script started
cleanup(){
	echo second script cleanup
	curl -X POST -d "second script cleanup $(date) $(hostname)" http://trap_exit.requestcatcher.com/test

}
curl -X POST -d "second script started $(date) $(hostname)" http://trap_exit.requestcatcher.com/test

trap cleanup EXIT
sleep 100000