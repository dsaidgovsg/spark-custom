#!/usr/bin/env bash
set -euo pipefail

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
    IMAGE_TEST_PREFIX=""
else
    IMAGE_TEST_PREFIX="test_"
fi

IMAGE_NAME=${IMAGE_NAME:-guangie88/spark-custom}
docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"
docker push "${IMAGE_NAME}:${IMAGE_TEST_PREFIX}${SPARK_VERSION}_hadoop-${HADOOP_VERSION}"
