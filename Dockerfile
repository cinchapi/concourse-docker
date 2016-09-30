FROM openjdk:8
MAINTAINER Brianna Fugate <bfugate@cinchapi.com>

ENV CONCOURSE_ARCHIVE_COMMIT_HASH a7d2efd52d9105c8163be6cf2b3a3d36f4d907cf
ENV CONCOURSE_ARCHIVE_FILE $CONCOURSE_ARCHIVE_COMMIT_HASH.tar.gz
ENV CONCOURSE_ARCHIVE_URL "https://github.com/cinchapi/concourse/archive/$CONCOURSE_ARCHIVE_FILE"
ENV CONCOURSE_SERVER_INSTALL_DIRECTORY /usr/local/opt/concourse
ENV CONCOURSE_SERVER_BUILD_DIRECTORY $CONCOURSE_SERVER_INSTALL_DIRECTORY/$CONCOURSE_ARCHIVE_COMMIT_HASH/concourse-server/build/distributions/concourse-server

VOLUME [ "/root/concourse" ]

RUN \
    mkdir -pv $CONCOURSE_SERVER_INSTALL_DIRECTORY && \
    cd $CONCOURSE_SERVER_INSTALL_DIRECTORY && \
    wget -O $CONCOURSE_ARCHIVE_FILE $CONCOURSE_ARCHIVE_URL && \
    mkdir -pv $CONCOURSE_ARCHIVE_COMMIT_HASH && \
    tar -C $CONCOURSE_ARCHIVE_COMMIT_HASH -f $CONCOURSE_ARCHIVE_FILE --strip-components=1 -xz && \
    cd $CONCOURSE_ARCHIVE_COMMIT_HASH && \
    ./gradlew clean installer && \
    cd ./concourse-server/build/distributions/ && \
    sh ./concourse-server-*.bin

WORKDIR $CONCOURSE_SERVER_BUILD_DIRECTORY

RUN \
    ln -fsv /dev/stdout ./log/console.log && \
    ln -fsv /dev/stdout ./log/debug.log && \
    ln -fsv /dev/stderr ./log/error.log && \
    ln -fsv /dev/stdout ./log/info.log && \
    ln -fsv /dev/stderr ./log/warn.log

CMD [ "./bin/concourse", "console" ]

EXPOSE 1717 8817
