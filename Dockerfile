FROM nvidia/cuda:8.0-cudnn6-devel
LABEL maintainer="Ming <i@ufoym.com>"

# =================================
# cuda          8.0
# cudnn         v6
# ---------------------------------
# python        2.7
# opencv        latest (git)
# ---------------------------------
# tensorflow    latest (pip)
# sonnet        latest (pip)
# pytorch       0.2.0  (pip)
# keras         latest (pip)
# mxnet         latest (pip)
# cntk          2.2    (pip)
# chainer       latest (pip)
# theano        latest (git)
# lasagne       latest (git)
# caffe         latest (git)
# torch         latest (git)
# ---------------------------------

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

# =================================
# apt
# =================================

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        apt-utils \
        && \

# =================================
# common tools
# =================================

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        ca-certificates \
        wget \
        git \
        vim \
        && \

# =================================
# cmake
# =================================

    # fix boost-not-found issue caused by the `apt-get` version of cmake
    $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    ./bootstrap --prefix=/usr/local && \
    make -j"$(nproc)" install

# =================================
# python2
# =================================
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
    
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python-pip \
        python-dev \
        && \
    ln -s /usr/bin/python /usr/local/bin/python && \
    pip --no-cache-dir install --upgrade pip && \
    $PIP_INSTALL \
        setuptools

RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
        $PIP_INSTALL \
        setuptools \
        numpy \
        scipy \
        pandas \
        scikit-learn \
        matplotlib \
        Cython \
        && \

# =================================
# opencv
# =================================

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        && \

    $GIT_CLONE https://github.com/opencv/opencv ~/opencv && \
    mkdir -p ~/opencv/build && cd ~/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_OPENCL=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          .. && \
    make -j"$(nproc)" install && \

# =================================
# tensorflow
# =================================

    $PIP_INSTALL \
        tensorflow_gpu \
        && \

# =================================
# sonnet
# =================================

    $PIP_INSTALL \
        dm-sonnet \
        && \

# =================================
# mxnet
# =================================

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        graphviz \
        && \

    $PIP_INSTALL \
        mxnet-cu80 \
        graphviz \
        && \


# =================================
# keras
# =================================

    $PIP_INSTALL \
        h5py \
        keras \
        && \

# =================================
# pytorch
# =================================

    $PIP_INSTALL \
        http://download.pytorch.org/whl/cu80/torch-0.2.0.post3-cp27-cp27mu-manylinux1_x86_64.whl \
        torchvision \
        && \

# =================================
# chainer
# =================================

    $PIP_INSTALL \
        cupy \
        chainer \
        && \

# =================================
# theano
# =================================

    $GIT_CLONE https://github.com/Theano/Theano ~/theano && \
    cd ~/theano && \
    $PIP_INSTALL \
        . && \

    $GIT_CLONE https://github.com/Theano/libgpuarray ~/gpuarray && \
    mkdir -p ~/gpuarray/build && cd ~/gpuarray/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          .. && \
    make -j"$(nproc)" install && \
    cd ~/gpuarray && \
    python setup.py build && \
    python setup.py install && \

    printf '[global]\nfloatX = float32\ndevice = cuda0\n\n[dnn]\ninclude_path = /usr/local/cuda/targets/x86_64-linux/include\n' \
    > ~/.theanorc && \

# =================================
# lasagne
# =================================

    $GIT_CLONE https://github.com/Lasagne/Lasagne ~/lasagne && \
    cd ~/lasagne && \
    $PIP_INSTALL \
        . && \

# =================================
# config & cleanup
# =================================

    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/*  ~/*
