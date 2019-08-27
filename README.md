# `spark-custom`

[![Build Status](https://travis-ci.org/guangie88/spark-custom.svg?branch=master)](https://travis-ci.org/guangie88/spark-custom)

Dockerfile set-up for custom Spark build releases. Builds for both Debian and
Alpine.

This set-up follows how Spark maintains their releases. As such, it builds for
the most recent two major.minor versions in the CI. All older versions are
removed from the list to build, but the already-built images will continue to
remain in the DockerHub repository and should remain usable.

Also, this set-up is able to use a fixed-up `hive-exec-1.2.1.spark2.jar` for
Hadoop 3 when using integration with Hive.

The current build arguments are supported:

- `SPARK_VERSION`: Full semver value of Spark to use. Example `2.4.0`.
- `HADOOP_VERSION`: Full server value of Hadoop to use. Example `3.1.0`.
- `WITH_HIVE`: Defaults to `"true"`. Install the integrated Hive at version
  `1.2.1-spark2`.
- `WITH_PYSPARK`: Defaults to `"true"`. Installs both Python 2 and 3 into the
  image, together with the standard `pyspark` package.

## How to Apply Travis Template

For Linux user, you can download Tera CLI v0.2 at
<https://github.com/guangie88/tera-cli/releases> and place it in `PATH`.

Otherwise, you will need `cargo`, which can be installed via
[rustup](https://rustup.rs/).

Once `cargo` is installed, simply run `cargo install tera-cli --version=^0.2.0`.
