FROM python 
MAINTAINER pejvan@gmail.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        libgtk2.0-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh tmp/Miniconda3-latest-Linux-x86_64.sh
RUN bash tmp/Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH $PATH:/root/miniconda3/bin/

COPY traffic-sign-classifier-environment.yml  .
RUN conda install --yes pyyaml
RUN conda env create python=3 -f traffic-sign-classifier-environment.yml

# resolve the missing opencv package issue with hdf5: 
# http://stackoverflow.com/questions/22589157/anaconda-doesnt-find-module-cv2
# RUN conda install -c anaconda hdf5=1.8.17 
#RUN conda install -c https://conda.anaconda.org/menpo opencv3
RUN conda install -c menpo opencv3=3.1.0
RUN conda install --name CarND-TensorFlow-Lab -c conda-forge tensorflow

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY . /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /
RUN chmod +x run_jupyter.sh

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/notebooks"

CMD ["/run_jupyter.sh"]
