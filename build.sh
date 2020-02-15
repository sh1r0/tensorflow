#!/usr/bin/env bash

set -e

DEST_DIR=tflite
LIB_DIR=${DEST_DIR}/lib
INCLUDE_DIR=${DEST_DIR}/include
TFLITE_HEXAGON_SKEL_RUNFILE=tflite-hexagon_nn_skel_1_10_3_1.run
TFLITE_HEXAGON_SKEL_DIR=hexagon_nn_skel_1_10_3_1
ZIP_FILE=tflite-$(git describe --tags).zip

bazel build --config=android_arm64 \
  tensorflow/lite/experimental/delegates/hexagon/hexagon_nn:libhexagon_interface.so
bazel build -c opt //tensorflow/lite:libtensorflowlite.so \
  --crosstool_top=//external:android/crosstool \
  --host_crosstool_top=@bazel_tools//tools/cpp:toolchain \
  --config=android_arm64 \
  --cpu=arm64-v8a

[ -d ${DEST_DIR} ] && rm -rf ${DEST_DIR}

mkdir -p ${LIB_DIR}
cp bazel-out/arm64-v8a-opt/bin/tensorflow/lite/libtensorflowlite.so ${LIB_DIR}
cp bazel-out/arm64-v8a-opt/bin/tensorflow/lite/experimental/delegates/hexagon/hexagon_nn/libhexagon_interface.so ${LIB_DIR}

[ -f ${TFLITE_HEXAGON_SKEL_RUNFILE} ] || \
  azcopy cp "https://aicscvdata.blob.core.windows.net/traffic-rule-violation-detection-assets/archive/${TFLITE_HEXAGON_SKEL_RUNFILE}${SAS_TOKEN}" .
[ -d ${TFLITE_HEXAGON_SKEL_DIR} ] || \
  echo "I ACCEPT" | sh ${TFLITE_HEXAGON_SKEL_RUNFILE}
cp ${TFLITE_HEXAGON_SKEL_DIR}/*.so ${LIB_DIR}

mkdir -p ${INCLUDE_DIR}
find tensorflow/lite -name '*.h' -exec rsync -R {} ${INCLUDE_DIR} \;
rsync -amR --include='*.h' --include='*/' --exclude='*' bazel-tensorflow/external/flatbuffers/include/./ ${INCLUDE_DIR}
rsync -amR --include='*.h' --include='*/' --exclude='*' bazel-tensorflow/external/com_google_absl/./ ${INCLUDE_DIR}

zip -r "${ZIP_FILE}" ${DEST_DIR}

[ -z "${SAS_TOKEN}" ] || \
  azcopy cp "${ZIP_FILE}" "https://aicscvdata.blob.core.windows.net/traffic-rule-violation-detection-assets/archive/${SAS_TOKEN}"
