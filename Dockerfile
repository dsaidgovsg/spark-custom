FROM openjdk:8-jdk-slim

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

# Must be able to match the hadoop-X.Y id
# See: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
# Hive integration with Spark is always at 1.2.1-spark2
ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

ARG WITH_HIVE="true"
ARG HIVE_HADOOP3_HIVE_EXEC_URL="https://github.com/guangie88/hive-exec-jar/releases/download/1.2.1.spark2-hadoop3/hive-exec-1.2.1.spark2.jar"

RUN set -eu && \
    # apt requirements
    apt-get update && apt-get -y --no-install-recommends install \
        curl \
        git \
        python \
        python-setuptools \
        ; \
    # Prep the Spark repo
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd spark; \
    # Spark installation
    HIVE_INSTALL_FLAG=$(if [ "${WITH_HIVE}" = "true" ]; then echo "-Phive"; fi); \
    ./dev/make-distribution.sh \
        --pip --name spark-${SPARK_VERSION}_hadoop-${HADOOP_VERSION} \
        -Phadoop-$(echo ${HADOOP_VERSION} | cut -c 1-3) \
        ${HIVE_INSTALL_FLAG} \
        -Dhadoop.version=${HADOOP_VERSION} \
        -DskipTests \
        ; \
    SPARK_ACTUAL_HOME=/opt/spark-${SPARK_VERSION}_hadoop-${HADOOP_VERSION}; \
    mv dist/ ${SPARK_ACTUAL_HOME}; \
    ln -s ${SPARK_ACTUAL_HOME} ${SPARK_HOME}; \
    # Replace Hive for Hadoop 3 since Hive 1.2.1 does not officially support Hadoop 3
    if [ "${WITH_HIVE}" = "true" ] && [ "$(echo ${HADOOP_VERSION} | cut -c 1)" == "3" ]; then \
        cd ${SPARK_HOME}/jars \
        curl -LO ${HIVE_HADOOP3_HIVE_EXEC_URL} \
    fi; \
    # apt clean-up
    apt-get remove -y \
        curl \
        git \
        python-setuptools \
        ; \
    rm -rf /var/lib/apt/lists/*; \
    :

ENV PATH ${PATH}:${SPARK_HOME}/bin
