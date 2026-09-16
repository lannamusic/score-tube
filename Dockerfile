FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/conda/bin:$PATH"
ENV PORT=10000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        bzip2 \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        mercurial \
        subversion \
        wget \
        ffmpeg \
        openjdk-8-jre && \
    rm -rf /var/lib/apt/lists/*

# Install Conda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    echo 'Downloading Miniconda3...' && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    conda config --set auto_update_conda False && \
    conda clean --all --yes

# Copy files and create conda environment
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD backend/environment.yml ./
RUN conda env create -f environment.yml && \
    conda clean --all --yes

# Copy application
ADD dist /usr/src/app/
ADD backend /usr/src/app/

EXPOSE 10000

CMD ["source /opt/conda/etc/profile.d/conda.sh && conda activate score-tube && exec gunicorn --bind=0.0.0.0:${PORT:-10000} --workers=2 --timeout 180 server:__hug_wsgi__"]
