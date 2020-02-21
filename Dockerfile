FROM openjdk:8-jdk-alpine

RUN apk add --update git bash

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
