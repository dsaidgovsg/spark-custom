# `spark-custom`

[![Build Status](https://travis-ci.org/guangie88/spark-custom.svg?branch=master)](https://travis-ci.org/guangie88/spark-custom)

Experimental Dockerfile set-up for custom Spark build releases. Builds for both
Debian and Alpine.

This set-up is able to use a fixed-up `hive-exec-1.2.1.spark2.jar` for Hadoop 3
when using integration with Hive.

The current build arguments are supported:

- `SPARK_VERSION`: Full semver value of Spark to use. Example `2.4.0`.
- `HADOOP_VERSION`: Full server value of Hadoop to use. Example `3.1.0`.
- `WITH_HIVE`: Defaults to `"true"`. Install the integrated Hive at version
  `1.2.1-spark2`.
- `WITH_PYSPARK`: Defaults to `"true"`. Installs both Python 2 and 3 into the
  image, together with the standard `pyspark` package.

## Generation of `.travis.yml`

This requires `python3` and `pip`. This will allow the installation of
`jinja2-cli`.

Run the following:

```bash
python3 -m pip install --user jinja2-cli[yaml]
```

Once installed, to generate the new `.travis.yml` file, run:

```bash
jinja2 .travis.yml.tmpl vars.yml > .travis.yml
```

As such, it is generally only necessary to update `vars.yml` to generate for
new Spark builds.
