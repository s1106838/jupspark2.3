FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.4.0

RUN pip install pip
RUN pip install pandas

#change to root
USER 0

LABEL io.k8s.description="PySpark Jupyter Notebook." \
      io.k8s.display-name="PySpark Jupyter Notebook." \
      io.openshift.expose-services="8888:http,42000:http,42100:http"


# expose a port for the workers to connect back
EXPOSE 42000/tcp
# also expose a port for the block manager
EXPOSE 42100/tcp

# install dep
RUN rpm -Uvh https://rpm.nodesource.com/pub_4.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm
RUN yum install -y nodejs

#upgrade nodejs
RUN npm cache clean -f
RUN npm install -g n
RUN n stable

#install git in jupyter
RUN pip install --upgrade jupyterlab-git

RUN jupyter labextension install @jupyterlab/git@^0.5.0 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging
    
#install pyspark    
RUN pip install pyspark


#install yarn client for spark & Hadoop because ??
RUN pip install yarn-api-client
    
#install spark
RUN cd /opt
RUN wget http://www-eu.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
RUN tar -xzf spark*
RUN ln -s /opt/spark* /opt/spark
RUN export SPARK_HOME=/opt/spark
RUN export PATH=$SPARK_HOME/bin:$PATH
RUN rm -rf /opt/app-root/src/*.tgz
    
#install java
RUN yum update -y && \
    yum install -y wget && \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all
        
#change to normal user    
USER 1001
RUN cd ~
