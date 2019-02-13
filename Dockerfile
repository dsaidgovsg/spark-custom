FROM debian:stretch-slim

ARG SPARK_VERSION=2.3.2
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION=2.3.2
ENV HADOOP_VERSION ${HADOOP_VERSION}

RUN set -eu && \
    apt-get update && apt-get -y --no-install-recommends install git; \
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    ./build/mvn -T 4 -Phadoop-${HADOOP_VERSION:0:3} -Dhadoop.version=${HADOOP_VERSION} -Phive -Phive-thriftserver -DskipTests clean package; \
    :
