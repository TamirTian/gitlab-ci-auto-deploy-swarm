FROM alpine:3.10.3
WORKDIR deploy
COPY enter.sh .
COPY create-template-with-env.sh .
COPY upgrade-service.sh .
COPY check-service.sh .

CMD enter.sh
