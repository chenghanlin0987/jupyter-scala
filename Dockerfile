FROM ubuntu:18.04
MAINTAINER BeeeeeMo

ENV DEBIAN_FRONTEND=noninteractive \
    SCALA_VERSION=2.12.8 \
    ALMOND_VERSION=0.3.1 \
    PYTHON_VERSION=3.6.6

USER root

RUN apt-get update && \
    apt-get install -y default-jre \
            default-jdk \
            wget \
            build-essential \
            libreadline-dev \
            zlib1g-dev \
            libssl-dev \
            libbz2-dev \
            libsqlite3-dev \
            libffi-dev \
            libevent-dev \
            python3-dev \
            libkrb5-dev \
            gcc \
            vim \
            curl && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /tmp/Python && \
    cd /tmp/Python && \
    wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz && \
    tar xvf Python-$PYTHON_VERSION.tar.xz && \
    cd /tmp/Python/Python-$PYTHON_VERSION && \ 
    ./configure --enable-optimizations && \
    make altinstall && \
    rm -rf /tmp/Python && \
    cd && \
    pip3.6 install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master && \
    jupyter contrib nbextension install 

# Scala install
RUN curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier bootstrap \
    -r jitpack \
    -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
    sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
    -o almond && \
    ./almond --install && \
    rm -f almond && \
    rm -f coursier

WORKDIR /root/

EXPOSE 8888

ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
CMD ["--NotebookApp.password=sha1:92564cf3d00c:f00f85a4a122d13ff2f3cdb11d734cfdcbc823b3"]
