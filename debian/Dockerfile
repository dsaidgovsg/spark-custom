# Expecting Debian images
ARG BUILDER_IMAGE=openjdk:8-jdk-slim
ARG RELEASE_IMAGE=openjdk:8-jre-slim

#
# Builder
#

FROM ${BUILDER_IMAGE} as builder
SHELL ["/bin/bash", "-c"]

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

# Must be able to match the hadoop-X.Y id
# See example: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

# Hive integration with Spark is always at 1.2.1-spark2
ARG WITH_HIVE="true"
ARG WITH_PYSPARK="true"
ARG HIVE_HADOOP3_HIVE_EXEC_URL="https://github.com/guangie88/hive-exec-jar/releases/download/1.2.1.spark2-hadoop3/hive-exec-1.2.1.spark2.jar"

RUN set -euo pipefail && \
    # Create Spark home
    mkdir -p $(dirname "${SPARK_HOME}"); \
    # apt requirements
    apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        ; \
    # Prep the Spark repo
    cd /; \
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd /spark; \
    # Spark installation
    ## Hive prep
    HIVE_INSTALL_FLAG=$(if [ "${WITH_HIVE}" = "true" ]; then echo "-Phive"; fi); \
    ## Pyspark prep
    apt-get install -y --no-install-recommends \
        python \
        python-setuptools \
        ; \
    PYSPARK_INSTALL_FLAG=$(if [ "${WITH_PYSPARK}" = "true" ]; then echo "--pip"; fi); \
    # Actual installation and release packaging
    ./dev/make-distribution.sh \
        ${PYSPARK_INSTALL_FLAG} --name spark-${SPARK_VERSION}_hadoop-${HADOOP_VERSION} \
        -Phadoop-$(echo ${HADOOP_VERSION} | cut -c 1-3) \
        ${HIVE_INSTALL_FLAG} \
        -Dhadoop.version=${HADOOP_VERSION} \
        -DskipTests \
        | awk 'NR % 50 == 0' \
        ; \
    mv /spark/dist/ ${SPARK_HOME}; \
    # Replace Hive for Hadoop 3 since Hive 1.2.1 does not officially support Hadoop 3
    if [ "${WITH_HIVE}" = "true" ] && [ "$(echo ${HADOOP_VERSION} | cut -c 1)" = "3" ]; then \
        (cd ${SPARK_HOME}/jars && curl -LO ${HIVE_HADOOP3_HIVE_EXEC_URL}); \
    fi; \
    # Pyspark clean-up
    if [ "${WITH_PYSPARK}" = "true" ]; then \
        apt-get remove -y \
            python-setuptools \
            ; \
    fi; \
    # Repo clean-up
    rm -rf /spark; \
    # apt clean-up
    apt-get remove -y \
        curl \
        git \
        ; \
    rm -rf /var/lib/apt/lists/*; \
    :

#
# Release
#

FROM ${RELEASE_IMAGE}
SHELL ["/bin/bash", "-c"]

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

ARG WITH_PYSPARK="true"

COPY --from=builder ${SPARK_HOME} ${SPARK_HOME}

RUN set -euo pipefail; \
    if [ "${WITH_PYSPARK}" = "true" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            python \
            python3 \
            ; \
        rm -rf /var/lib/apt/lists/*; \
    fi; \
    :

ENV PATH ${PATH}:${SPARK_HOME}/bin
