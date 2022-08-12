# syntax = docker/dockerfile:1.2
FROM alpine AS ngrok

WORKDIR /
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz
RUN tar -zxf ngrok-stable-linux-amd64.tgz

FROM clojure:tools-deps-1.11.1.1149 AS build

WORKDIR /guestbook/
COPY ./deps.edn /guestbook/
RUN clojure -P

COPY . /guestbook/
RUN clojure -T:build all

FROM azul/zulu-openjdk-alpine:18

WORKDIR /

RUN apk add openrc
RUN apk add openssh

RUN sed -ri 's/^.*AllowTcpForwarding.*$/AllowTcpForwarding yes/'        /etc/ssh/sshd_config
RUN sed -ri 's/^.*PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -ri 's/^.*PubkeyAuthentication.*$/PubkeyAuthentication yes/'    /etc/ssh/sshd_config
RUN sed -ri 's/^.*PermitEmptyPasswords.*$/PermitEmptyPasswords no/'     /etc/ssh/sshd_config
RUN sed -ri 's/^.*PermitEmptyPasswords .*$/PermitEmptyPasswords yes/'   /etc/ssh/sshd_config
RUN sed -ri 's/^.*PermitRootLogin .*$/PermitRootLogin yes/'             /etc/ssh/sshd_config


RUN mkdir -p /root/.ssh
RUN chmod 0700 ~/.ssh
COPY ./authorized_keys /authorized_keys
RUN mv /authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/authorized_keys
RUN passwd -u root

COPY --from=ngrok /ngrok /usr/local/bin/ngrok
COPY --from=build /guestbook/target/guestbook-standalone.jar /guestbook/guestbook-standalone.jar
COPY --from=build /guestbook/bin/docker-entrypoint /guestbook/docker-entrypoint

EXPOSE $PORT

CMD /guestbook/docker-entrypoint
