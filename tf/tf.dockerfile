ARG BASE_TAG=devel-gpu
FROM  tensorflow/tensorflow:${BASE_TAG}

# Setup working directory
RUN mkdir -p /usr/src
WORKDIR /usr/src
COPY . /usr/src

ARG BASE_TAG
ENV BASE_TAG=$BASE_TAG

# Build an image with this dockerfile and run ./build.sh to actually build TF
