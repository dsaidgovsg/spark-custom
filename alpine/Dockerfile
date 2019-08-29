# Expecting Alpine images
ARG BUILDER_IMAGE=openjdk:8-jdk-alpine
ARG RELEASE_IMAGE=openjdk:8-jre-alpine

#
# Builder
#

FROM ${BUILDER_IMAGE} as builder

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

# Must be able to match the hadoop-X.Y id
# See example: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

ARG PYTHON_VERSION
ENV PYTHON_VERSION "${PYTHON_VERSION}"

ARG PYTHON_HOME="/opt/python${PYTHON_VERSION}"
ENV PYTHON_HOME "${PYTHON_HOME}"

# Hive integration with Spark is always at 1.2.1-spark2
ARG WITH_HIVE="true"
ARG WITH_PYSPARK="true"
ARG HIVE_HADOOP3_HIVE_EXEC_URL="https://github.com/guangie88/hive-exec-jar/releases/download/1.2.1.spark2-hadoop3/hive-exec-1.2.1.spark2.jar"

RUN set -euo pipefail && \
    # Create Spark home
    mkdir -p $(dirname "${SPARK_HOME}"); \
    # apt requirements
    apk add --no-cache \
        curl \
        git \
        # For building Python adapted for Alpine: https://solarianprogrammer.com/2017/06/30/building-python-ubuntu-wsl-debian/
        build-base \
        openssl-dev zlib-dev ncurses-dev readline-dev sqlite-dev \
        ; \
    :

RUN set -euo pipefail && \
    # Install Python of specific version
    PY_PATCH_VERSION=-1 PY_PATCH_NEXT_VERSION=0; \
    while curl -fsI "https://www.python.org/ftp/python/${PYTHON_VERSION}.${PY_PATCH_NEXT_VERSION}/Python-${PYTHON_VERSION}.${PY_PATCH_NEXT_VERSION}.tar.xz" >/dev/null; do \
        PY_PATCH_VERSION="${PY_PATCH_NEXT_VERSION}"; \
        PY_PATCH_NEXT_VERSION=$((PY_PATCH_NEXT_VERSION+1)); \
    done; \
    if [ "${PY_PATCH_VERSION}" = "-1" ]; then \
        err () { >&2 echo "Python ${PYTHON_VERSION} does not exist for release!"; return $1; }; \
        err 1; \
    fi; \
    echo "Latest version for Python ${PYTHON_VERSION} is ${PYTHON_VERSION}.${PY_PATCH_VERSION}"; \
    cd /tmp; \
    curl -fsLO "https://www.python.org/ftp/python/${PYTHON_VERSION}.${PY_PATCH_VERSION}/Python-${PYTHON_VERSION}.${PY_PATCH_VERSION}.tar.xz"; \
    tar xf "Python-${PYTHON_VERSION}.${PY_PATCH_VERSION}.tar.xz"; \
    cd -; \
    cd "/tmp/Python-${PYTHON_VERSION}.${PY_PATCH_VERSION}"; \
    ./configure --enable-optimizations --without-ensurepip --prefix="${PYTHON_HOME}"; \
    CORES="$(grep -c ^processor /proc/cpuinfo)"; \
    make -j "${CORES}"; \
    make install; \
    "${PYTHON_HOME}/bin/python${PYTHON_VERSION}" -m pip install --upgrade pip; \
    cd -; \
    rm -rf "Python-${PYTHON_VERSION}.${PY_PATCH_VERSION}.tar.xz" "/tmp/Python-${PYTHON_VERSION}.${PY_PATCH_VERSION}"; \
    :

RUN set -euo pipefail && \
    # Prep the Spark repo
    cd /; \
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd /spark; \
    # Spark installation
    ## Hive prep
    HIVE_INSTALL_FLAG=$(if [ "${WITH_HIVE}" = "true" ]; then echo "-Phive"; fi); \
    ## Pyspark prep
    apk add --no-cache \
        bash \
        python2 \
        py-setuptools \
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
        apk del \
            py-setuptools \
            ; \
    fi; \
    # Repo clean-up
    rm -rf /spark; \
    # apk clean-up
    apk del \
        curl \
        git \
        build-base \
        openssl-dev zlib-dev ncurses-dev readline-dev sqlite-dev \
        ; \
    :

#
# Release
#

FROM ${RELEASE_IMAGE}

ARG SPARK_HOME=/opt/spark
ENV SPARK_HOME ${SPARK_HOME}

ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION}

ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION}

ARG PYTHON_VERSION
ENV PYTHON_VERSION "${PYTHON_VERSION}"

ARG PYTHON_HOME="/opt/python${PYTHON_VERSION}"
ENV PYTHON_HOME "${PYTHON_HOME}"

COPY --from=builder ${SPARK_HOME} ${SPARK_HOME}
COPY --from=builder ${PYTHON_HOME} ${PYTHON_HOME}

RUN set -euo pipefail; \
    PYTHON_MAJOR_VERSION="$(echo ${PYTHON_VERSION} | cut -d '.' -f1)"; \
    ln -s "${PYTHON_HOME}/bin/python${PYTHON_MAJOR_VERSION}" /usr/local/bin/python; \
    ln -s "${PYTHON_HOME}/bin/pydoc${PYTHON_MAJOR_VERSION}" /usr/local/bin/pydoc; \
    ln -s "${PYTHON_HOME}/bin/python${PYTHON_MAJOR_VERSION}-config" /usr/local/bin/python-config; \
    ln -s "${PYTHON_HOME}/bin/idle${PYTHON_MAJOR_VERSION}" /usr/local/bin/idle; \
    apk add --no-cache \
        bash \
        ; \
    :

ENV PATH="${PATH}:${PYTHON_HOME}/bin:${SPARK_HOME}/bin"
