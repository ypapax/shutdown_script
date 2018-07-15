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

repush(){
	push
	gcloud beta compute instances delete myinstance --quiet
	create_instance
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