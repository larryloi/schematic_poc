FROM ruby:2.6.10-alpine
LABEL maintainer="larry.loi@pm.me"

#RUN apk update && \
#    apk add bash mysql-client wget netcat-openbsd vim curl git nodejs freetds-dev build-base mariadb-connector-c-dev && \
#    rm -rf /var/cache/apk/*

RUN apk update && \
    apk add bash git nodejs curl freetds-dev build-base openssl && \
    rm -rf /var/cache/apk/*

RUN adduser -u 1001 -G users -D ds
USER ds

WORKDIR /app
ADD deploy /app/deploy
ADD Gemfile /app
ADD Makefile /app
ADD Rakefile.rb /app
ADD RELEASE /app
ADD src /app/src

### bundle install 
#RUN /bin/bash -l -c "bundle install"
#RUN /bin/bash -l -c "bundle install --without development"
RUN bundle config build.tiny_tds --with-freetds-dir=/usr/local
RUN bundle install --without development test


# CMD $REL_PATH/start-archive.sh
ENTRYPOINT ["/bin/bash", "-c"]
# CMD ["rake", "db:migrate"]
# CMD ["sleep", "infinity"]

LABEL application=schematic
