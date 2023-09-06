#!/bin/sh -eux

# export TVM_LOG_DEBUG="ir/transform.cc=1,relay/ir/transform.cc=1" # is really needed?
export TVM_HOME="${PWD}"
export PYTHONPATH="$TVM_HOME/python:${PYTHONPATH:-}"
export CC=/usr/lib/ccache/clang
export CXX=/usr/lib/ccache/clang++
export TVM_BACKTRACE=1

if [ ! -d "env" ]; then
  python3 -m venv env
  . env/bin/activate
  python3 -m pip install decorator psutil typing_extensions numpy scipy attrs onnx pillow
else
  . env/bin/activate
fi

mkdir -p build
(
  cd build
  cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
    -DUSE_LLVM=ON \
    -DUSE_OPENCL=ON \
    -DHIDE_PRIVATE_SYMBOLS=ON \
    -DUSE_ALTERNATIVE_LINKER=mold \
    -DUSE_OPENCL=ON \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -G Ninja \
    ..
  ninja
)

# PYTHONPATH="${PWD}/python" python -m pytest -n 1 ./tests/python/relay/test_pass_fake_quantization_to_integer.py

