FROM ubuntu:18.04
COPY xray /usr/bin/xray
COPY cfg.yaml /xray-daemon.yaml

EXPOSE 2000/tcp
EXPOSE 2000/udp

RUN apt-get update -y

ENV AWS_REGION us-east-1


ENTRYPOINT ["/usr/bin/xray", "--config", "/xray-daemon.yaml"]

CMD ['']
