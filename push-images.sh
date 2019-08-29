#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-spark-custom}
docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${SPARK_VERSION}_hadoop-${HADOOP_VERSION}"
