#!/usr/bin/env bash
set -ex

log=/var/log/entrypoint.log
exec > >(tee -i $log)
exec 2>&1

date
hostname

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
sleep 10000