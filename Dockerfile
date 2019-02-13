FROM openjdk:8-jdk-slim

ARG SPARK_VERSION=2.4.0
ENV SPARK_VERSION ${SPARK_VERSION}

# Must be able to match the hadoop-X.Y id
# See: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
ARG HADOOP_VERSION=3.1.0
ENV HADOOP_VERSION ${HADOOP_VERSION}

RUN set -eu && \
    # apt requirements
    apt-get update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        ; \
    # Spark installation
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd spark; \
    ./build/mvn -T 4 -Phadoop-$(echo ${HADOOP_VERSION} | cut -c 1-3) -Dhadoop.version=${HADOOP_VERSION} -Phive -Phive-thriftserver -DskipTests clean package; \
    # apt clean-up
    apt-get remove -y \
        ca-certificates \
        curl \
        git \
        ; \
    rm -rf /var/lib/apt/lists/*; \
    :
