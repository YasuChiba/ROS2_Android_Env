#!/bin/sh
set -e



ROS2_HOME_DIR=/root
ROS2_OUTPUT_DIR=/root/output
MICRO_XRCE_WS=${ROS2_HOME_DIR}/micro_xrce_ws

MICRO_XRCE_BUILD_DIR=${ROS2_OUTPUT_DIR}/build_isolated_micro_xrce
MICRO_XRCE_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_micro_xrce
AMENT_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_ament

ROS2_ANDROID_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_android


ANDROID_NDK_VERSION=android-ndk-r21b
export ANDROID_SDK=/opt/android/android-sdk-linux
export ANDROID_HOME=/opt/android/android-sdk-linux

ANDROID_TARGET=android-21
ANDROID_ABI=arm64-v8a


export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre






ANDROID_NDK=/opt/android/${ANDROID_NDK_VERSION}
TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
ANDROID_STL=c++_shared


#rm -rf ${MICRO_XRCE_WS}/src
#rm -rf $MICRO_XRCE_INSTALL_DIR
#rm -rf $MICRO_XRCE_BUILD_DIR

mkdir -p ${MICRO_XRCE_WS}/src


cd $MICRO_XRCE_WS
wget https://raw.githubusercontent.com/YasuChiba/Micro-XRCE-DDS-Agent/android-v1.1.0/micro_xrce_dds_agent.repos

vcs import $MICRO_XRCE_WS/src < micro_xrce_dds_agent.repos




cd ${MICRO_XRCE_WS}

. $AMENT_INSTALL_DIR/local_setup.sh



ament build   \
  --install-space $MICRO_XRCE_INSTALL_DIR \
  --build-space $MICRO_XRCE_BUILD_DIR \
  --cmake-args \
  -DTHIRDPARTY=ON \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE \
  -DANDROID_NATIVE_API_LEVEL=$ANDROID_TARGET \
  -DANDROID_STL=$ANDROID_STL \
  -DANDROID_ABI=$ANDROID_ABI \
  -DANDROID_NDK=$ANDROID_NDK \
  -DCMAKE_FIND_DEBUG_MODE=1 \
  -DUAGENT_SUPERBUILD=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DUAGENT_P2P_PROFILE=OFF \
  -DSPDLOG_BUILD_BENCH=OFF \
  -DCMAKE_FIND_ROOT_PATH="$MICRO_XRCE_BUILD_DIR;$MICRO_XRCE_INSTALL_DIR" \
  -DCMAKE_PREFIX_PATH=$MICRO_XRCE_INSTALL_DIR \
  -- \
  --ament-gradle-args \
  -Pament.android_stl=$ANDROID_STL -Pament.android_abi=$ANDROID_ABI -Pament.android_ndk=$ANDROID_NDK -- $@
