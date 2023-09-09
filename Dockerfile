FROM ubuntu:latest

WORKDIR /app

COPY *.sh /app/
COPY apps/* /app/apps/
COPY icons/* /app/icons/

CMD ["/bin/bash"]
