FROM ubuntu:16.04

# Set version and home folder
ENV DRUID_VERSION=0.12.2
ENV DRUID_HOME=/opt/druid

# Java 8
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && apt-add-repository -y ppa:webupd8team/java \
    && apt-get purge --auto-remove -y software-properties-common \
    && apt-get update \
    && echo oracle-java-8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer oracle-java8-set-default \
    && apt-get clean \
    && rm -rf /var/cache/oracle-jdk8-installer \
    && rm -rf /var/lib/apt/lists/*

# Druid system user
RUN adduser --system --group --no-create-home druid \
    && mkdir -p ${DRUID_HOME}

# Install Druid
RUN cd /tmp \
    && wget http://static.druid.io/artifacts/releases/druid-${DRUID_VERSION}-bin.tar.gz \
    && tar -xvf druid-${DRUID_VERSION}-bin.tar.gz \
    && mv druid-${DRUID_VERSION}/* ${DRUID_HOME} \
    && rm -fr ${DRUID_HOME}/conf-quickstart ${DRUID_HOME}/conf/* /tmp/* /var/tmp/*

# Install Druid extensions
RUN cd ${DRUID_HOME} \
    && java -cp "lib/*" -Ddruid.extensions.directory="extensions" io.druid.cli.Main tools pull-deps --no-default-hadoop -c "io.druid.extensions.contrib:druid-azure-extensions:0.12.1"

# Copy start script
COPY druid-entrypoint.sh ${DRUID_HOME}/druid-entrypoint.sh

RUN chmod +x ${DRUID_HOME}/druid-entrypoint.sh \
    && chown druid:druid -R ${DRUID_HOME}

# Expose ports:
# 8081 (Coordinator)
# 8082 (Broker)
# 8083 (Historical)
# 8088 (Router, if used)
# 8090 (Overlord)
# 8091, 8100–8199 (Druid Middle Manager; you may need higher than port 8199 if you have a very high druid.worker.capacity)
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 8091 8100-8199

USER druid
WORKDIR ${DRUID_HOME}
ENTRYPOINT [ "./druid-entrypoint.sh" ]
