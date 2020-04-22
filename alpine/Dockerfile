ARG PYTHON_VERSION

# Ideally both the Alpine version should match, but the Alpine versions
# for openjdk:8 is lagging behind
ARG ALPINE_COPY_FROM_DIST=alpine3.10
ARG ALPINE_DIST=alpine3.9

# Expecting Alpine images
ARG BUILDER_IMAGE=openjdk:8-jdk-${ALPINE_DIST}
ARG RELEASE_IMAGE=openjdk:8-jre-${ALPINE_DIST}

# This is solely for copying over
FROM python:${PYTHON_VERSION}-${ALPINE_COPY_FROM_DIST} as python_base

#
# Builder
#

FROM ${BUILDER_IMAGE} as builder

# Install Python by copying over from matching Alpine distribution for building
COPY --from=python_base /usr/local /usr/local
RUN set -euo pipefail && \
    # Required extra deps
    apk add --no-cache expat tk; \
    # Test every command to return non-error status code for help
    find /usr/local/bin -type f -perm /u=x,g=x,o=x -print0 | xargs -0 -I {} sh -c "{} --help || {} -h" >/dev/null 2>&1; \
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
    apk add --no-cache \
        bash \
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
    # Retry building on random failure
    for i in {1..5}; do \
        ./dev/make-distribution.sh \
            ${PYSPARK_INSTALL_FLAG} --name spark-${SPARK_VERSION}_hadoop-${HADOOP_VERSION} \
            -Pscala-${SCALA_VERSION} \
            -Phadoop-$(echo ${HADOOP_VERSION} | cut -d '.' -f1,2) \
            -Phadoop-cloud \
            ${HIVE_INSTALL_FLAG} \
            -Dhadoop.version=${HADOOP_VERSION} \
            -DskipTests \
            | awk 'NR % 50 == 0' \
            && break; \
        sleep 10; \
    done; \
    mv /spark/dist/ ${SPARK_HOME}; \
    # Replace Hive for Hadoop 3 since Hive 1.2.1 does not officially support Hadoop 3
    if [ "${WITH_HIVE}" = "true" ] && [ "$(echo ${HADOOP_VERSION} | cut -d '.' -f1)" = "3" ]; then \
        (cd ${SPARK_HOME}/jars && curl -LO ${HIVE_HADOOP3_HIVE_EXEC_URL}); \
    fi; \
    cd -; \
    # Repo clean-up
    rm -rf /spark; \
    # apk clean-up
    apk del \
        bash \
        curl \
        git \
        ; \
    :

#
# Release
#

FROM ${RELEASE_IMAGE}

# Install Python by copying over from matching Alpine distribution
COPY --from=python_base /usr/local /usr/local
RUN set -euo pipefail && \
    # Required extra deps
    apk add --no-cache expat tk; \
    # Test every command to return non-error status code for help
    find /usr/local/bin -type f -perm /u=x,g=x,o=x -print0 | xargs -0 -I {} sh -c "{} --help || {} -h" >/dev/null 2>&1; \
    :

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

COPY --from=builder ${SPARK_HOME} ${SPARK_HOME}

RUN set -euo pipefail; \
    apk add --no-cache \
        bash \
        openssl \
        ; \
    :

ENV PATH="${PATH}:${SPARK_HOME}/bin"
