# syntax = docker/dockerfile:1.2
FROM alpine AS ngrok

WORKDIR /
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz
RUN tar -zxf ngrok-stable-linux-amd64.tgz

FROM clojure:tools-deps-1.11.1.1149 AS build

WORKDIR /guestbook/
COPY . /guestbook/

RUN clj -Sforce -T:build all

FROM azul/zulu-openjdk-alpine:18

COPY --from=ngrok /ngrok /usr/local/bin/ngrok
COPY --from=build /guestbook/target/guestbook-standalone.jar /guestbook/guestbook-standalone.jar
COPY --from=build /guestbook/bin/docker-entrypoint /guestbook/docker-entrypoint

EXPOSE $PORT
EXPOSE 7001

CMD /guestbook/docker-entrypoint
