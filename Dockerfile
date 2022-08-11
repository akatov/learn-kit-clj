# syntax = docker/dockerfile:1.2
FROM clojure:tools-deps-1.11.1.1149 AS build

WORKDIR /guestbook/
COPY . /guestbook/

RUN clj -Sforce -T:build all

FROM azul/zulu-openjdk-alpine:18

COPY --from=build /guestbook/target/guestbook-standalone.jar /guestbook/guestbook-standalone.jar

EXPOSE $PORT

ENTRYPOINT exec java $JAVA_OPTS -jar /guestbook/guestbook-standalone.jar
