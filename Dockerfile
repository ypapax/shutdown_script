FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl
ADD entrypoint.sh /entrypoint.sh
ADD second_script.sh /second_script.sh
ENTRYPOINT ["/entrypoint.sh"]
