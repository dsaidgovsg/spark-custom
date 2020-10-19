# `spark-custom`

![CI Status](https://img.shields.io/github/workflow/status/dsaidgovsg/spark-custom/CI/master?label=CI&logo=github&style=for-the-badge)

Dockerfile set-up for custom Spark build releases. Builds for both Debian and
Alpine.

This set-up follows how Spark maintains their releases. As such, it builds for
the most recent two release versions in the CI. All older versions are removed
from the list to build, but the already-built images will continue to remain in
the DockerHub repository and should remain usable.

Also, this set-up is able to use a fixed-up `hive-exec-1.2.1.spark2.jar` for
Hadoop 3 when using integration with Hive.

The current build arguments are supported:

- `SPARK_VERSION`: `x.y.z` version of Spark to use. Example `2.4.7`.
- `SCALA_VERSION`: `x.y` version of Scala to use. Example `2.11` and `2.12`.
- `HADOOP_VERSION`: `x.y.z` of Hadoop to use. Example `3.1.0`.
- `PYTHON_VERSION`: `x.y` server value of Hadoop to use. Example `3.7`.
- `WITH_HIVE`: Defaults to `"true"`. Install the integrated Hive at version
  `1.2.1-spark2`.
- `WITH_PYSPARK`: Defaults to `"true"`. Installs the `pyspark` package.

## How to Apply Template for CI build

For Linux user, you can download Tera CLI v0.3 at
<https://github.com/guangie88/tera-cli/releases> and place it in `PATH`.

Otherwise, you will need `cargo`, which can be installed via
[rustup](https://rustup.rs/).

Once `cargo` is installed, simply run `cargo install tera-cli --version=^0.3.0`.
