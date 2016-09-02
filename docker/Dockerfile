FROM dylanmei/zeppelin:latest


RUN rm $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z/note.json
RUN rmdir $ZEPPELIN_NOTEBOOK_DIR/2A94M5J1Z

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

CMD ["bin/zeppelin.sh"]
