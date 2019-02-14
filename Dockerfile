FROM openjdk:8-jdk-slim

ARG SPARK_VERSION=2.4.0
ENV SPARK_VERSION ${SPARK_VERSION}

# Must be able to match the hadoop-X.Y id
# See: https://github.com/apache/spark/blob/v2.4.0/pom.xml#L2692
# Also see Hive compatibility with Spark
# See: https://cwiki.apache.org/confluence/display/Hive/Hive+on+Spark%3A+Getting+Started
# and: https://archive.apache.org/dist/hive/
ARG HADOOP_VERSION=3.1.0
ENV HADOOP_VERSION ${HADOOP_VERSION}

ARG HIVE_VERSION=3.0.0
ENV HIVE_VERSION ${HIVE_VERSION}

RUN set -eu && \
    # apt requirements
    apt-get update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        ; \
    # Prep the Spark repo
    git clone https://github.com/apache/spark.git -b v${SPARK_VERSION}; \
    cd spark; \
    # Modify the pom.xml to get better Hive support
    # sed -i 's/org\.spark-project\.hive/org.apache.hive/' pom.xml; \
    # cat pom.xml; \
    # Spark installation
    ./build/mvn -T 4 -Phadoop-$(echo ${HADOOP_VERSION} | cut -c 1-3) \
        # -Phive \
        # -Phive-thriftserver \
        -Dhadoop.version=${HADOOP_VERSION} \
        # This normally comes withs suffix ".spark2", seems to suggest special variant
        # -Dhive.version=${HIVE_VERSION} \
        # -Dhive.version.short=${HIVE_VERSION} \
        # -Dhive.group="org.apache.hive" \
        -DskipTests \
        clean package; \
    # apt clean-up
    rm -rf /var/lib/apt/lists/*; \
    :
