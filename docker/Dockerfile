FROM ruby:2.6.10
LABEL maintainer="larry.loi@pm.me"

RUN apt-get update && \
    apt-get install -y mysql-common apt-utils wget netcat-openbsd vim curl git bsd-mailx nodejs libv8-dev curl freetds-dev && \
    apt-get clean

#ENV BUNDLE_PATH=vendor/bundle
#ENV BUNDLE_GLOBAL_PATH_APPENDS_RUBY_SCOPE=1

WORKDIR /app
ADD . /app

### bundle install 
#RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "bundle install --without development"

# CMD $REL_PATH/start-archive.sh
ENTRYPOINT ["/bin/bash", "-c"]
# CMD ["rake", "db:migrate"]
# CMD ["sleep", "infinity"]


LABEL application=schematic
