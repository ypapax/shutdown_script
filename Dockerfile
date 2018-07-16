FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl
RUN mkdir /root/second-script
ADD entrypoint.sh /entrypoint.sh
ADD second_script.sh /second-script/second_script.sh
ENTRYPOINT ["/entrypoint.sh"]
