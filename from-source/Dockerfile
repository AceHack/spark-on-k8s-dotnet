# References
# https://github.com/docker-library/openjdk/blob/master/8/jdk/slim/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/bindings/R/Dockerfile
# https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/bindings/python/Dockerfile
# https://github.com/dotnet/spark/blob/master/docs/building/ubuntu-instructions.md
# https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites?tabs=netcore30


# Spark args
ARG SPARK_TAG=master
ARG HADOOP_PROFILE=hadoop-3.2
ARG SCALA_BINARY_VERSION=2.12
ARG SCALA_VERSION=2.12.8

# Java args
ARG JAVA_VERSION=8u222

# R args
ARG CRAN_MIRROR=https://cloud.r-project.org/

# Maven args
ARG MAVEN_VERSION=3.6.1

# dotnet args
ARG DOTNET_VERSION=3.0.0-preview8-28405-07
ARG ASPNETCORE_VERSION=3.0.0-preview8.19405.7
ARG DOTNET_SDK_VERSION=3.0.100-preview8-013656

# dotnet spark args
ARG SPARK_DOTNET_TAG=master
ARG SPARK_DOTNET_TARGET_FRAMEWORK=netcoreapp2.1

# Prometheus args
ARG PROMETHEUS_EXPORTER_VERSION=0.12.0


# References
# https://github.com/debuerreotype/docker-debian-artifacts/blob/dist-amd64/buster/Dockerfile
# https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/buster/curl/Dockerfile
# https://github.com/docker-library/buildpack-deps/blob/master/buster/scm/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/3.0/sdk/buster/amd64/Dockerfile
# http://spark.apache.org/docs/latest/building-spark.html
# https://github.com/apache/spark/commit/f15102b1702b64a54233ae31357e32335722f4e5#diff-180360612c6b8c4ed830919bbb4dd459
# https://github.com/dotnet/corefx/blob/master/pkg/Microsoft.NETCore.Platforms/runtime.json
FROM buildpack-deps:buster-scm as build

# Spark args
ARG SPARK_TAG
ARG HADOOP_PROFILE
ARG SCALA_BINARY_VERSION
ARG SCALA_VERSION
ARG SPARK_SOURCE_FILE=${SPARK_TAG}.tar.gz
ARG SPARK_SOURCE_URL=https://github.com/apache/spark/archive/${SPARK_SOURCE_FILE}

# Java args
ARG JAVA_VERSION
ARG JAVA_URL_VERSION=${JAVA_VERSION}b10
ARG JAVA_BASE_URL=https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk${JAVA_VERSION}-b10/OpenJDK8U-jdk_

# R args
ARG CRAN_MIRROR

# Maven args
ARG MAVEN_VERSION
ARG MAVEN_BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# dotnet args
ARG DOTNET_SDK_VERSION
ARG DOTNET_SDK_URL=https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz

# dotnet spark args
ARG SPARK_DOTNET_TAG
ARG SPARK_DOTNET_TARGET_FRAMEWORK
ARG SPARK_DOTNET_SOURCE_FILE=${SPARK_DOTNET_TAG}.tar.gz
ARG SPARK_DOTNET_SOURCE_URL=https://github.com/dotnet/spark/archive/${SPARK_DOTNET_SOURCE_FILE}

# Linux vars
ENV DEBIAN_FRONTEND=noninteractive

# Java vars
ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/local/openjdk-8
ENV PATH=$JAVA_HOME/bin:$PATH

# R vars
ENV R_HOME=/usr/lib/R \
    NO_MANUAL=1

# dotnet vars
ENV DOTNET_ROOT=/usr/share/dotnet \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip

# Maven vars
ENV MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m" \
    MAVEN_HOME=/usr/share/maven

# Linux update
RUN set -eux && \
    apt-get update && \
    apt-get install -y \
        apt-utils && \
    apt-get upgrade -y
WORKDIR /build

# Spark deps
RUN apt-get install -y \
        bash libnss3 libpam-modules wget curl

# Java deps
RUN apt-get install -y \
        ca-certificates p11-kit wget dirmngr gnupg

# Python deps
RUN apt-get install -y \
        python python-setuptools python-pip python-pypandoc \
        python3 python3-setuptools python3-pip python3-pypandoc && \
    python --version && \
    pip --version && \
    python2 --version && \
    pip2 --version && \
    python3 --version && \
    pip3 --version

# R deps
RUN apt-get install -y \
        r-base r-base-dev \
        build-essential libssl-dev libssh2-1-dev libcurl4-openssl-dev libxml2-dev libgit2-dev \
        texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra && \
        R --version

# dotnet deps
RUN apt-get install -y \
        ca-certificates curl libcurl4 liblttng-ust0 libkrb5-3 libunwind8 libuuid1 \
        libc6 libgcc1 libgssapi-krb5-2 libicu63 libssl1.1 libstdc++6 zlib1g

# Python pam setup
RUN echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

# Java install
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ] && \
	dpkgArch="$(dpkg --print-architecture)" && \
	case "$dpkgArch" in \
		amd64) upstreamArch='x64' ;; \
		arm64) upstreamArch='aarch64' ;; \
		*) echo >&2 "error: unsupported architecture: $dpkgArch" ;; \
	esac && \
	wget -O openjdk.tgz.asc "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz.sign" && \
	wget -O openjdk.tgz "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz" --progress=dot:giga && \
	mkdir -p "$JAVA_HOME" && \
	tar --extract \
		--file openjdk.tgz \
		--directory "$JAVA_HOME" \
		--strip-components 1 \
		--no-same-owner && \
	rm openjdk.tgz* && \
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "$JAVA_HOME" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
		echo 'cacertsFile=; for f in "$JAVA_HOME/lib/security/cacerts" "$JAVA_HOME/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in $JAVA_HOME"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk && \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk && \
	/etc/ca-certificates/update.d/docker-openjdk && \
	find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf && \
	ldconfig && \
	javac -version && \
	java -version

# Maven install
RUN mkdir -p ${MAVEN_HOME}/ref && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C ${MAVEN_HOME} --strip-components=1 && \
    rm -f /tmp/apache-maven.tar.gz && \
    ln -svf ${MAVEN_HOME}/bin/mvn /usr/bin/mvn && \
    mvn --version

# dotnet install
RUN curl -SL --output dotnet.tar.gz ${DOTNET_SDK_URL} && \
    mkdir -p ${DOTNET_ROOT} && \
    tar -zxf dotnet.tar.gz -C ${DOTNET_ROOT} && \
    rm dotnet.tar.gz && \
    ln -s ${DOTNET_ROOT}/dotnet /usr/bin/dotnet && \
    dotnet --info

# Spark source install
RUN mkdir -p spark && \
    wget ${SPARK_SOURCE_URL} && \
    tar xvzf ${SPARK_SOURCE_FILE} -C spark --strip-components=1 && \
    rm -f ${SPARK_SOURCE_FILE}

# dotnet spark source install
RUN mkdir -p spark/dotnet && \
    wget ${SPARK_DOTNET_SOURCE_URL} && \
    tar xvzf ${SPARK_DOTNET_SOURCE_FILE} -C spark/dotnet --strip-components=1 && \
    rm -f ${SPARK_DOTNET_SOURCE_FILE}

# R deps
RUN R -e "install.packages(c('knitr', 'rmarkdown', 'e1071', 'survival', 'digest', 'crayon', 'praise', 'magrittr', 'R6'), repos='${CRAN_MIRROR}')" && \
    R -e "install.packages('${CRAN_MIRROR}src/contrib/Archive/testthat/testthat_1.0.2.tar.gz', repos=NULL, type='source')"

# Spark build
WORKDIR /build/spark 
RUN ./dev/change-scala-version.sh ${SCALA_BINARY_VERSION} && \
    ./dev/make-distribution.sh --name spark --pip --r -DskipTests -Dscala.binary.version=${SCALA_BINARY_VERSION} -Dscala.version=${SCALA_VERSION} -P${HADOOP_PROFILE} -Psparkr -Pkubernetes -Pyarn -Phive -Phive-thriftserver

# dotnet spark build
WORKDIR /build/spark/dotnet
RUN cd src/scala && \
    mvn -pl -microsoft-spark-2.3.x clean package -Dscala.binary.version=${SCALA_BINARY_VERSION} -Dscala.version=${SCALA_VERSION} && \
    cd ../csharp/Microsoft.Spark.Worker && \
    dotnet publish -c Release -f ${SPARK_DOTNET_TARGET_FRAMEWORK} -r debian.10-x64 && \
    cd ../../../examples/Microsoft.Spark.CSharp.Examples && \
    dotnet publish -c Release -f ${SPARK_DOTNET_TARGET_FRAMEWORK} -r debian.10-x64 && \
    cd ../Microsoft.Spark.FSharp.Examples && \
    dotnet publish -c Release -f ${SPARK_DOTNET_TARGET_FRAMEWORK} -r debian.10-x64


# References
# https://github.com/debuerreotype/docker-debian-artifacts/blob/dist-amd64/buster/slim/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/3.0/runtime-deps/buster-slim/amd64/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/3.0/runtime/buster-slim/amd64/Dockerfile
# https://github.com/dotnet/dotnet-docker/blob/master/3.0/aspnet/buster-slim/amd64/Dockerfile
# https://github.com/dotnet/spark/blob/master/deployment/install-worker.sh
# https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/spark-docker/Dockerfile
FROM openjdk:${JAVA_VERSION}-jdk-slim-buster as runtime

# dotnet args
ARG DOTNET_VERSION
ARG ASPNETCORE_VERSION
ARG DOTNET_URL=https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-x64.tar.gz
ARG ASPNETCORE_URL=https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-x64.tar.gz

# dotnet spark args
ARG SPARK_DOTNET_TARGET_FRAMEWORK

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

# Prometheus args
ARG PROMETHEUS_EXPORTER_VERSION

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
        ca-certificates curl libcurl4 liblttng-ust0 libkrb5-3 libunwind8 libuuid1 \
        libc6 libgcc1 libgssapi-krb5-2 libicu63 libssl1.1 libstdc++6 zlib1g

# Python pam setup
RUN echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

# Replace sh with bash and fix tini
RUN rm -f /bin/sh && \
    ln -svf /bin/bash /bin/sh && \
    ln -svf /usr/bin/tini /sbin/tini

# dotnet install
RUN curl -SL --output dotnet.tar.gz ${DOTNET_URL} && \
    mkdir -p ${DOTNET_ROOT} && \
    tar -zxf dotnet.tar.gz -C ${DOTNET_ROOT} && \
    rm dotnet.tar.gz && \
    ln -svf ${DOTNET_ROOT}/dotnet /usr/bin/dotnet && \
    curl -SL --output aspnetcore.tar.gz ${ASPNETCORE_URL} && \
    tar -zxf aspnetcore.tar.gz -C ${DOTNET_ROOT} ./shared/Microsoft.AspNetCore.App && \
    rm aspnetcore.tar.gz && \
    dotnet --info

# Spark install
RUN mkdir -p ${SPARK_HOME}/work-dir && \
    ln -svf ${DOTNET_ROOT}/dotnet ${SPARK_HOME}/work-dir/dotnet && \
    touch ${SPARK_HOME}/RELEASE
COPY --from=build /build/spark/dist/kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY --from=build /build/spark/dist/jars ${SPARK_HOME}/jars
COPY --from=build /build/spark/dist/bin ${SPARK_HOME}/bin
COPY --from=build /build/spark/dist/sbin ${SPARK_HOME}/sbin
COPY --from=build /build/spark/dist/examples ${SPARK_HOME}/examples
COPY --from=build /build/spark/dist/kubernetes/tests ${SPARK_HOME}/tests
COPY --from=build /build/spark/dist/data ${SPARK_HOME}/data
COPY --from=build /build/spark/dist/python/lib ${SPARK_HOME}/python/lib
COPY --from=build /build/spark/dist/R ${SPARK_HOME}/R
RUN spark-submit --version

# dotnet spark install
COPY --from=build /build/spark/dotnet/src/scala/microsoft-spark-2.4.x/target/*.jar ${SPARK_HOME}/jars
COPY --from=build /build/spark/dotnet/artifacts/bin/Microsoft.Spark.Worker/Release/${SPARK_DOTNET_TARGET_FRAMEWORK}/debian.10-x64/publish ${DOTNET_WORKER_DIR}
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
