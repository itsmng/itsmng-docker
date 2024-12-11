FROM debian:bookworm-slim

RUN apt update && apt install -y netcat-traditional 

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD exit
