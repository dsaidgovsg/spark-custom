#!/usr/bin/env bash
set -euo pipefail

echo "${DOCKER_PASSWORD}" | docker login -u="${DOCKER_USERNAME}" --password-stdin

IMAGE_NAME=${IMAGE_NAME:-spark-custom}

TAG_NAME="${SELF_VERSION}_${SPARK_VERSION}_scala-${SCALA_VERSION}_hadoop-${HADOOP_VERSION}_python-${PYTHON_VERSION}${HIVE_TAG_SUFFIX}${PYSPARK_TAG_SUFFIX}_${DIST}"
docker tag "${IMAGE_NAME}:${TAG_NAME}" "${IMAGE_ORG}/${IMAGE_NAME}:${TAG_NAME}"
docker push "${IMAGE_ORG}/${IMAGE_NAME}:${TAG_NAME}"

ALT_TAG_NAME="${SPARK_VERSION}_scala-${SCALA_VERSION}_hadoop-${HADOOP_VERSION}_python-${PYTHON_VERSION}${HIVE_TAG_SUFFIX}${PYSPARK_TAG_SUFFIX}_${DIST}"
docker tag "${IMAGE_NAME}:${TAG_NAME}" "${IMAGE_ORG}/${IMAGE_NAME}:${ALT_TAG_NAME}"
docker push "${IMAGE_ORG}/${IMAGE_NAME}:${ALT_TAG_NAME}"
