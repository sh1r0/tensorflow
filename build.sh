#!/usr/bin/env bash

set -e

DEST_DIR=tflite
LIB_DIR=${DEST_DIR}/lib
INCLUDE_DIR=${DEST_DIR}/include

mkdir -p ${LIB_DIR}
cp bazel-out/arm64-v8a-opt/bin/tensorflow/lite/libtensorflowlite.so ${LIB_DIR}

mkdir -p ${INCLUDE_DIR}
find tensorflow/lite -name '*.h' -exec rsync -R {} ${INCLUDE_DIR} \;

zip -r "tflite-$(git describe --tags).zip" ${DEST_DIR}
