FROM dylanmei/zeppelin:latest

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

#ADD ttra-assembly.jar /usr/zeppelin/interpreter/spark/dep/
ADD ttra-assembly.jar /usr/zeppelin/

CMD ["bin/zeppelin.sh"]
