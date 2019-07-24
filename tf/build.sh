#!/bin/bash
set -ex

# Pull latest master
cd /tensorflow_src
git pull

# Use the default configuration
yes '' | ./configure

# Check if we should add GPU flags
if [[ $BASE_TAG == *"gpu"* ]]; then
    ADDITIONAL_FLAGS="--config=cuda"
else
    ADDITIONAL_FLAGS=""
fi

# Build the c_api
bazel build --config=opt $ADDITIONAL_FLAGS //tensorflow/tools/lib_package:libtensorflow

# Copy libtensorflow to the dist folder
mkdir -p /dist
cp "bazel-bin/tensorflow/tools/lib_package/libtensorflow.tar.gz" "/dist/libtensorflow-gpu-$(git rev-parse HEAD).tar.gz"

# Build the pip package and copy it to the dist folder
mkdir -p /tmp_dist
bazel build --config=opt $ADDITIONAL_FLAGS //tensorflow/tools/pip_package:build_pip_package
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp_dist
cp "/tmp_dist/*.whl" "/dist/tensorflow-$(git rev-parse HEAD).whl"
