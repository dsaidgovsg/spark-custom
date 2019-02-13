FROM debian:stretch-slim

ARG SPARK_VERSION=2.3.2
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION=3.2.0
ENV HADOOP_VERSION ${HADOOP_VERSION}

RUN set -eu && \
    apt-get update && apt-get -y --no-install-recommends install \
        ca-certificates \
        git \
        ; \
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd spark; \
    ./build/mvn -T 4 -Phadoop-$(echo ${HADOOP_VERSION} | cut -c 1-3) -Dhadoop.version=${HADOOP_VERSION} -Phive -Phive-thriftserver -DskipTests clean package; \
    :
