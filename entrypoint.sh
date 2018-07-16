#!/usr/bin/env bash
set -ex

log=/var/log/entrypoint.log
exec > >(tee -i $log)
exec 2>&1

date
hostname

cleanup(){
	pkill -ef go_app
	curl -X POST -d "cleanup is called for $(hostname) $(date)" http://trap_exit.requestcatcher.com/test
	echo cleanup is called
	curl -X POST -d "cleanup is called log: $(cat $log)" http://trap_exit.requestcatcher.com/test
	pkill -ef second_script.sh
	curl -X POST -d "after calling pkill: $(cat $log)" http://trap_exit.requestcatcher.com/test

}

trap cleanup EXIT
curl -X POST -d "container is started on $(hostname) $(date)" http://trap_exit.requestcatcher.com/test
ls -la /root/scripts
/root/go_app -v 4 -alsologtostderr -name app1 &
/root/go_app -v 4 -alsologtostderr -name app2 &
/root/scripts/second_script.sh -D

sleep 10000