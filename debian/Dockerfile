ARG PYTHON_VERSION
ARG DEBIAN_DIST=buster

# Expecting Debian images
ARG BUILDER_IMAGE=openjdk:8-jdk-slim-${DEBIAN_DIST}
ARG RELEASE_IMAGE=openjdk:8-jre-slim-${DEBIAN_DIST}

# This is solely for copying over
FROM python:${PYTHON_VERSION}-${DEBIAN_DIST} as python_base

#
# Builder
#

FROM ${BUILDER_IMAGE} as builder
SHELL ["/bin/bash", "-c"]

# Install Python by copying over from matching Debian distribution for building
COPY --from=python_base /usr/local /usr/local
RUN set -euo pipefail && \
    # Required extra deps
    apt-get update && apt-get install --no-install-recommends -y libexpat1 tk; \
    rm -rf /var/lib/apt/lists/*; \
    ldconfig; \
    # Test every command to return non-error status code for help
    find /usr/local/bin -type f -perm /u=x,g=x,o=x -print0 | xargs -0 -I {} bash -c "{} --help || {} -h" >/dev/null 2>&1; \
    :

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME "${SPARK_HOME}"

ARG SPARK_VERSION
ENV SPARK_VERSION "${SPARK_VERSION}"

ARG SCALA_VERSION
ENV SCALA_VERSION "${SCALA_VERSION}"

# Must be able to match the hadoop-X.Y id
# See example: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
ARG HADOOP_VERSION
ENV HADOOP_VERSION "${HADOOP_VERSION}"

# Hive integration with Spark is always at 1.2.1-spark2
ARG WITH_HIVE="true"
ARG WITH_PYSPARK="true"
ARG HIVE_HADOOP3_HIVE_EXEC_URL="https://github.com/guangie88/hive-exec-jar/releases/download/1.2.1.spark2-hadoop3/hive-exec-1.2.1.spark2.jar"

RUN set -euo pipefail && \
    # Santity check
    if [ "${SCALA_VERSION}" != "2.11" ] && [ "${SCALA_VERSION}" != "2.12" ]; then \
        >&2 echo "SCALA_VERSION must be either 2.11 or 2.12!"; \
        exit 1; \
    fi; \ 
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
    PYSPARK_INSTALL_FLAG=$(if [ "${WITH_PYSPARK}" = "true" ]; then echo "--pip"; fi); \
    # Actual installation and release packaging
    ./dev/change-scala-version.sh "${SCALA_VERSION}"; \
    ./dev/make-distribution.sh \
        ${PYSPARK_INSTALL_FLAG} --name spark-${SPARK_VERSION}_hadoop-${HADOOP_VERSION} \
        -Pscala-${SCALA_VERSION} \
        -Phadoop-$(echo ${HADOOP_VERSION} | cut -d '.' -f1,2) \
        -Phadoop-cloud \
        ${HIVE_INSTALL_FLAG} \
        -Dhadoop.version=${HADOOP_VERSION} \
        -DskipTests \
        ; \
    mv /spark/dist/ ${SPARK_HOME}; \
    # Replace Hive for Hadoop 3 since Hive 1.2.1 does not officially support Hadoop 3
    # Spark 3 doesn't require it since it uses an updated Hive 2.3 JAR
    if [ "${WITH_HIVE}" = "true" ] && [ "$(echo ${HADOOP_VERSION} | cut -d '.' -f1)" = "3" ] && [ "$(echo ${SPARK_VERSION} | cut -d '.' -f1)" != "3" ]; then \
        (cd ${SPARK_HOME}/jars && curl -LO ${HIVE_HADOOP3_HIVE_EXEC_URL}); \
    fi; \
    cd -; \
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

# Install Python by copying over from matching Debian distribution
COPY --from=python_base /usr/local /usr/local
RUN set -euo pipefail && \
    # Required extra deps
    apt-get update && apt-get install --no-install-recommends -y libexpat1 tk; \
    rm -rf /var/lib/apt/lists/*; \
    ldconfig; \
    # Test every command to return non-error status code for help
    find /usr/local/bin -type f -perm /u=x,g=x,o=x -print0 | xargs -0 -I {} bash -c "{} --help || {} -h" >/dev/null 2>&1; \
    :

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

COPY --from=builder ${SPARK_HOME} ${SPARK_HOME}

RUN set -euo pipefail; \
    apt-get update && apt-get install -y --no-install-recommends \
        openssl \
        ; \
    rm -rf /var/lib/apt/lists/*; \
    :

ENV PATH="${PATH}:${SPARK_HOME}/bin"
