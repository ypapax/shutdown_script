FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
