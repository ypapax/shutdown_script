FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN mkdir /root/second-script
COPY entrypoint.sh /root/scripts/entrypoint.sh
COPY second_script.sh /root/scripts/second_script.sh
COPY go_app/go_app /root/go_app

CMD ["/root/go_app", "-alsologtostderr", "-v", "4", "-name", "app1"]
CMD ["/root/go_app", "-alsologtostderr", "-v", "4", "-name", "app2"]