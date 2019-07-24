FROM soumith/conda-cuda

# Setup working directory
RUN mkdir -p /usr/src
WORKDIR /usr/src
COPY . /usr/src

# Whether or not to use CUDA
ARG USE_CUDA
ENV USE_CUDA=$USE_CUDA

# If we're using CUDA, what version should we use
ARG TARGET_CUDA_VERSION=10.0
ENV TARGET_CUDA_VERSION=$TARGET_CUDA_VERSION

# Set a variant name for the artifacts
ARG VARIANT_NAME
ENV VARIANT_NAME=$VARIANT_NAME

# Build an image with this dockerfile and run ./build.sh to actually build torch
