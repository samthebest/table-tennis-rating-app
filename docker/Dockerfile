####
#### Copy pasted from https://github.com/dylanmei/docker-zeppelin/blob/master/Dockerfile
####

FROM gettyimages/spark:2.1.1-hadoop-2.7

# SciPy
RUN set -ex \
 && buildDeps=' \
    libpython3-dev \
    build-essential \
    pkg-config \
    gfortran \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends \
    $buildDeps \
    ca-certificates \
    wget \
    liblapack-dev \
    libopenblas-dev \
 && packages=' \
    numpy \
    pandasql \
    scipy \
 ' \
 && pip3 install $packages \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_COMMIT v0.7.2
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
    npm \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps

RUN curl -sL http://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/ \
 && git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin \
 && cd /usr/src/zeppelin \
 && git checkout -q $ZEPPELIN_COMMIT

# Reskinning
#ADD index.html /usr/src/zeppelin/index.html
ADD navbar.html /usr/src/zeppelin/navbar.html
#ADD navbar.css /usr/src/zeppelin/navbar.css
ADD home.css /usr/src/zeppelin/home.css
#ADD pom.xml /usr/src/zeppelin/pom.xml

# this is buggy, seems to cause issues
#RUN mv /usr/src/zeppelin/index.html /usr/src/zeppelin/zeppelin-web/src/index.html
#RUN mv /usr/src/zeppelin/navbar.css /usr/src/zeppelin/zeppelin-web/src/components/navbar/navbar.css
RUN mv /usr/src/zeppelin/navbar.html /usr/src/zeppelin/zeppelin-web/src/components/navbar/navbar.html
RUN mv /usr/src/zeppelin/home.css /usr/src/zeppelin/zeppelin-web/src/app/home/home.css

#RUN rm /usr/src/zeppelin/zeppelin-web/src/assets/images/zepLogo.png /usr/src/zeppelin/zeppelin-web/src/assets/images/zepLogoW.png

RUN cd /usr/src/zeppelin \
 && dev/change_scala_version.sh "2.11" \
 && MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" /tmp/apache-maven-3.5.0/bin/mvn --batch-mode package -DskipTests -Pscala-2.11 -Pbuild-distr \
  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution'

RUN cd /usr/src/zeppelin \
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

RUN rm -f /usr/bin/python || true

RUN ln -s /usr/bin/pip3 /usr/bin/pip \
 && ln -s /usr/bin/python3 /usr/bin/python

# ADD about.json $ZEPPELIN_NOTEBOOK_DIR/2BTRWA9EV/note.json
WORKDIR $ZEPPELIN_HOME

####
#### End copy paste
####

RUN rm $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z/note.json
RUN rmdir $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z

ADD log4j.properties /usr/zeppelin/conf/

COPY notebooks/ $ZEPPELIN_NOTEBOOK_DIR/

# We put these notebooks into a directory called docker to simplify scripts
RUN mkdir -p $ZEPPELIN_HOME/docker/
# We also add the template & demo notebooks into /usr/zeppelin/ for easy named access
COPY demo-notebooks/ $ZEPPELIN_HOME/docker/demo-notebooks
COPY template-notebooks/ $ZEPPELIN_HOME/docker/template-notebooks
COPY test-notebooks/ $ZEPPELIN_HOME/docker/test-notebooks

# This has stopped working, so have to load jar using %dep
# I tried REALLY hard to use the following via the API, but the API sucks
# https://zeppelin.apache.org/docs/0.6.0/manual/dependencymanagement.html

ADD ttra-assembly.jar /usr/zeppelin/

CMD ["bin/zeppelin.sh"]
