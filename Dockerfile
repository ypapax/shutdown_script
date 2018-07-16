FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl
RUN mkdir /root/second-script
COPY entrypoint.sh /root/scripts/entrypoint.sh
COPY second_script.sh /root/scripts/second_script.sh
COPY go_app/go_app /root/go_app
ENTRYPOINT ["/root/scripts/entrypoint.sh"]
