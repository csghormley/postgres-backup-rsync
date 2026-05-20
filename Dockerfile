FROM postgres:17-alpine

RUN apk add --no-cache \
    rsync \
    openssh-client \
    bash

COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

CMD ["/backup.sh"]
