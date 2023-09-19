FROM ruby:2.6.10-alpine
LABEL maintainer="larry.loi@pm.me"

#RUN apk update && \
#    apk add bash mysql-client wget netcat-openbsd vim curl git nodejs freetds-dev build-base mariadb-connector-c-dev && \
#    rm -rf /var/cache/apk/*

RUN apk update && \
    apk add bash mysql-client git nodejs curl freetds-dev build-base mariadb-connector-c-dev && \
    rm -rf /var/cache/apk/*

WORKDIR /app
ADD . /app

### bundle install 
#RUN /bin/bash -l -c "bundle install"
#RUN /bin/bash -l -c "bundle install --without development"
RUN bundle config build.tiny_tds --with-freetds-dir=/usr/local
RUN bundle install


# CMD $REL_PATH/start-archive.sh
ENTRYPOINT ["/bin/bash", "-c"]
# CMD ["rake", "db:migrate"]
# CMD ["sleep", "infinity"]


LABEL application=schematic
