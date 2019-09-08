# References
# https://github.com/debuerreotype/docker-debian-artifacts/blob/dist-amd64/buster/slim/Dockerfile
# https://github.com/docker-library/openjdk/blob/master/8/jdk/slim/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/2.1/runtime-deps/stretch-slim/amd64/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/2.2/runtime/stretch-slim/amd64/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/2.2/aspnet/stretch-slim/amd64/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/bindings/R/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/bindings/python/Dockerfile
# https://github.com/dotnet/spark/blob/master/docs/getting-started/ubuntu-instructions.md
# https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites?tabs=netcore2x


# Spark args
ARG SPARK_VERSION=2.4.3
ARG SPARK_SUFFIX=hadoop2.7

# Java args
ARG JAVA_VERSION=8u222

# dotnet args
ARG DOTNET_PACKAGE=aspnetcore-runtime-2.2
ARG DOTNET_SDK_PACKAGE=dotnet-sdk-2.2

# dotnet spark args
ARG SPARK_DOTNET_VERSION=0.4.0
ARG SPARK_DOTNET_TARGET_FRAMEWORK=netcoreapp2.1

# Prometheus args
ARG PROMETHEUS_EXPORTER_VERSION=0.12.0


# References
# https://dotnet.microsoft.com/download/linux-package-manager/debian9/sdk-2.2.401
FROM openjdk:${JAVA_VERSION}-jdk-slim-buster as build

# Spark args
ARG SPARK_VERSION
ARG SPARK_SUFFIX
ARG SPARK_FILE=spark-${SPARK_VERSION}-bin-${SPARK_SUFFIX}.tgz
ARG SPARK_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_FILE}

# dotnet args
ARG DOTNET_SDK_PACKAGE

# dotnet spark args
ARG SPARK_DOTNET_VERSION
ARG SPARK_DOTNET_TARGET_FRAMEWORK
ARG SPARK_DOTNET_FILE=Microsoft.Spark.Worker.${SPARK_DOTNET_TARGET_FRAMEWORK}.linux-x64-${SPARK_DOTNET_VERSION}.tar.gz
ARG SPARK_DOTNET_SOURCE_FILE=v${SPARK_DOTNET_VERSION}.tar.gz
ARG SPARK_DOTNET_URL=https://github.com/dotnet/spark/releases/download/v${SPARK_DOTNET_VERSION}/${SPARK_DOTNET_FILE}
ARG SPARK_DOTNET_SOURCE_URL=https://github.com/dotnet/spark/archive/${SPARK_DOTNET_SOURCE_FILE}

# Linux vars
ENV DEBIAN_FRONTEND=noninteractive

# dotnet vars
ENV DOTNET_ROOT=/usr/share/dotnet \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip

# Linux update
RUN set -eux && \
    apt-get update && \
    apt-get install -y \
        apt-utils && \
    apt-get upgrade -y
WORKDIR /build

# Spark deps
RUN apt-get install -y --no-install-recommends \
        wget curl

# dotnet deps
RUN apt-get install -y \
        apt-transport-https gnupg && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/debian/10/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -y \
        ${DOTNET_SDK_PACKAGE} && \
    dotnet --info

# Spark install
RUN mkdir -p spark && \
    wget ${SPARK_URL} && \
    tar xvzf ${SPARK_FILE} -C spark --strip-components=1 && \
    rm -f ${SPARK_FILE}

# dotnet spark install
RUN mkdir -p spark/dotnet/worker && \
    wget ${SPARK_DOTNET_URL} && \
    tar xvzf ${SPARK_DOTNET_FILE} -C spark/dotnet/worker --strip-components=1 && \
    rm -f ${SPARK_DOTNET_FILE} && \
    cd spark/dotnet && \
    dotnet new classlib && \
    dotnet add package Microsoft.Spark --version ${SPARK_DOTNET_VERSION} && \
    dotnet add package Microsoft.Spark.Experimental --version ${SPARK_DOTNET_VERSION} && \
    dotnet publish -c Release -r debian.10-x64

# dotnet spark source install
RUN mkdir -p spark/dotnet && \
    wget ${SPARK_DOTNET_SOURCE_URL} && \
    tar xvzf ${SPARK_DOTNET_SOURCE_FILE} -C spark/dotnet --strip-components=1 && \
    rm -f ${SPARK_DOTNET_SOURCE_FILE}

# dotnet spark build
WORKDIR /build/spark/dotnet
RUN cd examples/Microsoft.Spark.CSharp.Examples && \
    dotnet publish -c Release -f ${SPARK_DOTNET_TARGET_FRAMEWORK} -r debian.10-x64 && \
    cd ../Microsoft.Spark.FSharp.Examples && \
    dotnet publish -c Release -f ${SPARK_DOTNET_TARGET_FRAMEWORK} -r debian.10-x64


# References
# https://dotnet.microsoft.com/download/linux-package-manager/debian9/runtime-2.2.6
# https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/spark-docker/Dockerfile
FROM openjdk:${JAVA_VERSION}-jdk-slim-buster as runtime

# dotnet args
ARG DOTNET_PACKAGE

# dotnet spark args
ARG SPARK_DOTNET_TARGET_FRAMEWORK

# Prometheus args
ARG PROMETHEUS_EXPORTER_VERSION

# Spark vars
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Python vars
ENV PYTHONPATH=${SPARK_HOME}/python/lib/pyspark.zip:${SPARK_HOME}/python/lib/py4j-*.zip

# R vars
ENV R_HOME=/usr/lib/R

# dotnet vars
ENV DOTNET_ROOT=/usr/share/dotnet \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true

# dotnet spark vars
ENV DOTNET_WORKER_DIR=${SPARK_HOME}/dotnet/worker
ENV SPARKDOTNET_ROOT=${DOTNET_WORKER_DIR} \
    DOTNET_WORKER=${DOTNET_WORKER_DIR}/Microsoft.Spark.Worker

# Linux update
RUN set -eux && \
    apt-get update && \
    apt-get upgrade -y

# Spark deps
RUN apt-get install -y --no-install-recommends \
        bash tini libnss3 libpam-modules wget curl

# Python deps
RUN apt-get install -y --no-install-recommends \
        python python-setuptools python-pip \
        python3 python3-setuptools python3-pip && \
    python --version && \
    pip --version && \
    python2 --version && \
    pip2 --version && \
    python3 --version && \
    pip3 --version

# R deps
RUN apt-get install -y --no-install-recommends \
        r-base r-base-dev && \
    R --version

# dotnet deps
RUN apt-get install -y --no-install-recommends \
        apt-transport-https gnupg && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/debian/10/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ${DOTNET_PACKAGE} && \
    dotnet --info

# Python pam setup
RUN echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

# Replace sh with bash and fix tini
RUN rm -f /bin/sh && \
    ln -svf /bin/bash /bin/sh && \
    ln -svf /usr/bin/tini /sbin/tini

# Spark install
RUN mkdir -p ${SPARK_HOME}/work-dir && \
    ln -svf /usr/bin/dotnet ${SPARK_HOME}/work-dir/dotnet && \
    touch ${SPARK_HOME}/RELEASE
COPY --from=build /build/spark/kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY --from=build /build/spark/jars ${SPARK_HOME}/jars
COPY --from=build /build/spark/bin ${SPARK_HOME}/bin
COPY --from=build /build/spark/sbin ${SPARK_HOME}/sbin
COPY --from=build /build/spark/examples ${SPARK_HOME}/examples
COPY --from=build /build/spark/kubernetes/tests ${SPARK_HOME}/tests
COPY --from=build /build/spark/data ${SPARK_HOME}/data
COPY --from=build /build/spark/python/lib ${SPARK_HOME}/python/lib
COPY --from=build /build/spark/R ${SPARK_HOME}/R
RUN spark-submit --version

# dotnet spark install
COPY --from=build /build/spark/dotnet/bin/Release/netstandard2.0/debian.10-x64/publish/microsoft-spark-2.4.x-*.jar ${SPARK_HOME}/jars
COPY --from=build /build/spark/dotnet/worker ${DOTNET_WORKER_DIR}
COPY --from=build /build/spark/dotnet/artifacts/bin/Microsoft.Spark.CSharp.Examples/Release/${SPARK_DOTNET_TARGET_FRAMEWORK}/debian.10-x64/publish ${SPARK_HOME}/work-dir
COPY --from=build /build/spark/dotnet/artifacts/bin/Microsoft.Spark.FSharp.Examples/Release/${SPARK_DOTNET_TARGET_FRAMEWORK}/debian.10-x64/publish ${SPARK_HOME}/work-dir
RUN chmod +x ${DOTNET_WORKER} && \
    ln -svf ${DOTNET_WORKER} /usr/local/bin/Microsoft.Spark.Worker

# Setup for the Prometheus JMX exporter.
RUN mkdir -p /etc/metrics/conf
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${PROMETHEUS_EXPORTER_VERSION}/jmx_prometheus_javaagent-${PROMETHEUS_EXPORTER_VERSION}.jar /prometheus/
COPY prometheus-conf/metrics.properties /etc/metrics/conf
COPY prometheus-conf/prometheus.yaml /etc/metrics/conf

# Entrypoint
WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]
