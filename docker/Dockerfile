FROM ubuntu:16.04

# SciPy
RUN set -ex \
 && buildDeps=' \
    libpython3-dev \
    build-essential \
    pkg-config \
    gfortran \
    r-base \
    r-base-dev \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends \
    $buildDeps \
    ca-certificates \
    wget \
    curl \
    liblapack-dev \
    libopenblas-dev \
    python3-pip \
 && packages=' \
    numpy \
    scipy \
 ' \
 && pip3 install $packages \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# JAVA
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=92
ARG JAVA_BUILD_NUMBER=14
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

# http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz
ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/jdk-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

# jq (install now we have run apt-get update)
RUN echo "deb http://us.archive.ubuntu.com/ubuntu vivid main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install jq

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
    r-base \
    r-base-dev \
    less \
    vim \
    libcurl4-openssl-dev \
    libssl-dev    \
    net-tools \
    dnsutils \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/

RUN echo test

# FIXME The following command appears to succeed even when it fails to install things due to network issues. FRTB-232
RUN echo ' r = getOption("repos") \n \
r["CRAN"] = "http://cloud.r-project.org/" \n \
options(repos = r)                         \n \
rm(r)                                      \n  \
install.packages("ggplot2")                \n  \
install.packages("knitr")                  \n \
install.packages("data.table")             \n \
install.packages("devtools")             \n \
install.packages("xts")             \n \
install.packages("reshape2")             \n \
install.packages("plyr")             \n \

' \
| R --vanilla

RUN echo "require(devtools);install_github('rCharts', 'ramnathv') " | R --vanilla
RUN echo "install.packages('googleVis',repos = 'http://cloud.r-project.org/')"  | R --vanilla



ADD zeppelin /usr/src/zeppelin
#-pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hive,hbase,postgresql,jdbc,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution' \

# && sed -i 's/--no-color/buildSkipTests --no-color/' zeppelin-web/pom.xml \
RUN mkdir -p /root/.m2 && rm -r /root/.m2/repository || true

ADD maven_repo /root/.m2/repository
ADD npm_repo /root/.npm

RUN cd /usr/src/zeppelin \
 && MAVEN_OPTS="-Xms512m -Xmx1024m" /tmp/apache-maven-3.3.9/bin/mvn  package  -DskipTests -Pyarn -Pspark-1.6  -Dspark.version=1.6.2 -Pbuild-distr  -Psparkr   \
 && tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/ \
 && mv /usr/zeppelin* $ZEPPELIN_HOME \
 && mkdir -p $ZEPPELIN_HOME/logs \
 && mkdir -p $ZEPPELIN_HOME/run \
 && apt-get purge -y --auto-remove $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/src/zeppelin \
 && rm -rf /root/.m2 \
 && rm -rf /root/.npm \
 && rm -rf /tmp/*

RUN rm $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z/note.json
RUN rmdir $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z

WORKDIR $ZEPPELIN_HOME

RUN mkdir -p host-volume

ADD bin/zeppelin-env.sh /usr/zeppelin/conf/zeppelin-env.sh

ADD bin/ttra.sh bin/ttra.sh
ADD bin/utils.sh bin/utils.sh

ADD log4j.properties /usr/zeppelin/conf/

ADD bin/file-server.py /usr/zeppelin/bin/file-server.py

ADD bin/file-server.sh /usr/zeppelin/bin/file-server.sh

COPY file-server-dir /usr/zeppelin/file-server-dir

COPY notebooks/ $ZEPPELIN_NOTEBOOK_DIR/

# We put these notebooks into a directory called docker to simplify scripts
RUN mkdir -p $ZEPPELIN_HOME/docker/
# We also add the template & demo notebooks into /usr/zeppelin/ for easy named access
COPY demo-notebooks/ $ZEPPELIN_HOME/docker/demo-notebooks
COPY template-notebooks/ $ZEPPELIN_HOME/docker/template-notebooks
COPY test-notebooks/ $ZEPPELIN_HOME/docker/test-notebooks

ADD ttra-assembly.jar /usr/zeppelin/interpreter/spark/dep/

CMD ["bin/ttra.sh"]