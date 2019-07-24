#!/bin/bash
set -ex

# Activate conda
. /opt/conda/etc/profile.d/conda.sh
conda activate base

# Set the cuda version
# based on https://raw.githubusercontent.com/pytorch/builder/master/conda/switch_cuda_version.sh
CUDA_DIR="/usr/local/cuda-$TARGET_CUDA_VERSION"
if ! ls "$CUDA_DIR"
then
    echo "folder $CUDA_DIR not found"
    # (This exit isn't in the original script)
    exit 1
fi

echo "Switching symlink to $CUDA_DIR"
mkdir -p /usr/local
rm -fr /usr/local/cuda
ln -s "$CUDA_DIR" /usr/local/cuda

export CUDA_VERSION=$(ls /usr/local/cuda/lib64/libcudart.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev)
export CUDNN_VERSION=$(ls /usr/local/cuda/lib64/libcudnn.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev)

# Install torch deps and build
# Based on https://github.com/pytorch/pytorch#from-source
# and https://github.com/pytorch/pytorch/blob/master/docs/libtorch.rst
conda install -y numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing zip unzip

# Get the source
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch

# Build a wheel
python setup.py bdist_wheel

# Build libtorch
mkdir build_libtorch
pushd build_libtorch
python ../tools/build_libtorch.py
popd

# Based on https://github.com/pytorch/builder/blob/master/manywheel/build_common.sh#L138
mkdir -p libtorch/{lib,bin,include,share}
cp -r build_libtorch/build/lib libtorch/
ANY_WHEEL=$(ls dist/torch*.whl | head -n1)
unzip -d any_wheel $ANY_WHEEL
if [[ -d any_wheel/torch/include ]]; then
    cp -r any_wheel/torch/include libtorch/
else
    cp -r any_wheel/torch/lib/include libtorch/
fi
cp -r any_wheel/torch/share/cmake libtorch/share/
rm -rf any_wheel

GIT_HASH="$(cd /usr/src/pytorch && git rev-parse HEAD)"
echo $GIT_HASH > libtorch/build-hash

# Package the artifacts
mkdir -p /dist
zip -rq /dist/libtorch-$VARIANT_NAME-$GIT_HASH.zip libtorch
cp /usr/src/pytorch/dist/*.whl /dist/torch-$VARIANT_NAME-$GIT_HASH.whl
find /dist
