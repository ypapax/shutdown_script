#!/usr/bin/env bash
set -ex
build(){
	cd $GOPATH/src/github.com/shutdown_script
	docker build -t ypapax/trap_exit .
}

push(){
	build
	cd $GOPATH/src/github.com/shutdown_script
	docker push ypapax/trap_exit
}

comp(){
	cd $GOPATH/src/github.com/shutdown_script
	docker-compose build
	docker-compose up
}

create_instance(){
	cd $GOPATH/src/github.com/shutdown_script
	gcloud beta compute instances create-with-container myinstance \
	--container-image ypapax/trap_exit #\
#	--metadata-from-file shutdown-script=./on_shutdown.sh

}

repush(){
	push
	gcloud beta compute instances delete myinstance --quiet
	create_instance
	ssh
}

ssh(){
	gcloud compute ssh myinstance
}

logs(){
	gcloud beta logging read 'resource.type=global AND jsonPayload.instance.name=myinstance' \
		--freshness 600s \
		--order=desc \
		--limit=100 \
		--format=json \
		 | jq  'reverse' \
		 | jq  -C '.[] | .timestamp + "  " + .jsonPayload.data'

}

$@