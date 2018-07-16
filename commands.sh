#!/usr/bin/env bash
set -ex
build(){
	build_go
	cd $GOPATH/src/github.com/ypapax/shutdown_script
	docker build -t ypapax/trap_exit .
}

push(){
	build
	cd $GOPATH/src/github.com/ypapax/shutdown_script
	docker push ypapax/trap_exit
}

comp(){
	build_go
	cd $GOPATH/src/github.com/ypapax/shutdown_script
	docker-compose build
	docker-compose up
}

create_instance(){
	cd $GOPATH/src/github.com/ypapax/shutdown_script
	gcloud beta compute instances create-with-container myinstance \
	--container-image ypapax/trap_exit #\
#	--metadata-from-file shutdown-script=./on_shutdown.sh

}

template(){
	gcloud beta compute instance-templates create-with-container my-template \
     --container-image ypapax/trap_exit
}

group(){
	gcloud compute instance-groups managed create mygroup \
    --base-instance-name mygroup \
    --size 1 \
    --template my-template \
    --zone europe-west1-b
}

repush_with_delete(){
	push
	set +e; delete; set -e
	create_instance
	ssh
}

delete(){
	gcloud beta compute instances delete myinstance --quiet
}
repush(){

	push
	reboot
	ssh
}

repush2(){
	push
	template
	group
}

delete2(){
	gcloud compute instance-groups managed delete mygroup --quiet
	gcloud beta compute instance-templates delete my-template --quiet
}
ssh(){
	gcloud compute ssh myinstance
}

reboot(){
	gcloud compute ssh myinstance -- "sudo reboot"
}

logs(){
	gcloud beta logging read 'resource.type=global AND jsonPayload.instance.name=myinstance' \
		--freshness 600s \
		--order=desc \
		--limit=1000 \
		--format=json \
		 | jq  'reverse' \
		 | jq  -C '.[] | .timestamp + "  " + .jsonPayload.data'

}

resize(){
	size=$1
	if [ -z "$size" ]; then
		size=2 # default is 2
	fi
	gcloud compute instance-groups managed resize mygroup --size=$size
}

list(){
	gcloud compute instances list
}

build_go(){
	cd $GOPATH/src/github.com/ypapax/shutdown_script/go_app
	GOOS=linux GOARCH=amd64 go build
}

$@