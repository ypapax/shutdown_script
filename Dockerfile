FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get -y install supervisor

RUN mkdir /root/second-script
COPY entrypoint.sh /root/scripts/entrypoint.sh
COPY second_script.sh /root/scripts/second_script.sh
COPY go_app/go_app /root/go_app

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/tini", "--", "/root/scripts/entrypoint.sh"]