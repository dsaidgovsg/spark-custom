# `spark-custom`

Experimental Dockerfile set-up for custom Spark build releases.

This set-up is able to use a fixed-up `hive-exec-1.2.1.spark2.jar` with using
integration with Hive.

The current build arguments are supported:

- `SPARK_VERSION`: Full semver value of Spark to use. Example `2.4.0`.
- `HADOOP_VERSION`: Full server value of Hadoop to use. Example `3.1.0`.
- `WITH_HIVE`: Defaults to `"true"`. Install the integrated Hive at version
  `1.2.1-spark2`.
- `WITH_PYSPARK`: Defaults to `"true"`. Installs both Python 2 and 3 into the
  image, together with the standard `pyspark` package.
