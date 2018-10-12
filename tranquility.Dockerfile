FROM ubuntu:16.04

# Set version and home folder
ENV TRANQUILITY_VERSION=0.8.2
ENV TRANQUILITY_HOME=/opt/druid/tranquility

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
    && mkdir -p ${TRANQUILITY_HOME}

# Install Druid
RUN cd /tmp \
    && wget http://static.druid.io/tranquility/releases/tranquility-distribution-${TRANQUILITY_VERSION}.tgz \
    && tar -xzf tranquility-distribution-${TRANQUILITY_VERSION}.tgz \
    && mv tranquility-distribution-${TRANQUILITY_VERSION}/* ${TRANQUILITY_HOME} \
    && rm -fr /tmp/* /var/tmp/* ${TRANQUILITY_HOME}/conf/* tranquility-distribution-${TRANQUILITY_VERSION}.tgz

# Copy start script
COPY tranquility-entrypoint.sh ${TRANQUILITY_HOME}/tranquility-entrypoint.sh

RUN chmod +x ${TRANQUILITY_HOME}/tranquility-entrypoint.sh \
    && chown druid:druid -R ${TRANQUILITY_HOME}

# Expose ports:
# 8200 (Tranquility Server, if used)
EXPOSE 8200

USER druid
WORKDIR ${TRANQUILITY_HOME}
ENTRYPOINT [ "./tranquility-entrypoint.sh" ]
