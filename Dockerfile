FROM ubuntu
RUN apt-get update
RUN apt-get -y install curl

RUN apt-get -y install supervisor

RUN mkdir /root/second-script
COPY entrypoint.sh /root/scripts/entrypoint.sh
COPY second_script.sh /root/scripts/second_script.sh
COPY go_app/go_app /root/go_app

COPY supervisord1.conf /etc/supervisor/conf.d/supervisord1.conf
COPY supervisord2.conf /etc/supervisor/conf.d/supervisord2.conf

ENTRYPOINT ["/root/scripts/entrypoint.sh"]