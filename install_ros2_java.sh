#!/bin/sh
set -e



ROS2_HOME_DIR=/root
ROS2_OUTPUT_DIR=/root/output
ROS2_ANDROID_WS=${ROS2_HOME_DIR}/ros2_android_ws
ROS2_ANDROID_BUILD_DIR=${ROS2_OUTPUT_DIR}/build_isolated_android
ROS2_ANDROID_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_android
AMENT_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_ament



ANDROID_NDK_VERSION=android-ndk-r21b
export ANDROID_SDK=/opt/android/android-sdk-linux
export ANDROID_HOME=/opt/android/android-sdk-linux

ANDROID_TARGET=android-21
ANDROID_ABI=arm64-v8a


export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre



ANDROID_NDK=/opt/android/${ANDROID_NDK_VERSION}
TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
ANDROID_STL=c++_shared

#rm -rf ${ROS2_ANDROID_WS}/src
#rm -rf $ROS2_ANDROID_INSTALL_DIR
#rm -rf $ROS2_ANDROID_BUILD_DIR


mkdir -p ${ROS2_ANDROID_WS}/src

cd $ROS2_ANDROID_WS
#wget https://raw.githubusercontent.com/esteve/ros2_java/master/ros2_java_android.repos
wget https://raw.githubusercontent.com/YasuChiba/ros2_java/working/ros2_java_android.repos
vcs import $ROS2_ANDROID_WS/src < ros2_java_android.repos

#
. $AMENT_INSTALL_DIR/local_setup.sh



#--only-packages ros2_listener_android
cd $ROS2_ANDROID_WS
ament build --skip-packages test_msgs \
  --isolated --install-space $ROS2_ANDROID_INSTALL_DIR --build-space $ROS2_ANDROID_BUILD_DIR --cmake-args \
  -DTHIRDPARTY=ON \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE \
  -DANDROID_FUNCTION_LEVEL_LINKING=OFF -DANDROID_NATIVE_API_LEVEL=$ANDROID_TARGET -DANDROID_STL=$ANDROID_STL \
  -DANDROID_ABI=$ANDROID_ABI -DANDROID_NDK=$ANDROID_NDK -DTHIRDPARTY=ON -DCOMPILE_EXAMPLES=OFF -DCMAKE_FIND_ROOT_PATH="$AMENT_INSTALL_DIR;$ROS2_ANDROID_INSTALL_DIR" \
  -- \
  --ament-gradle-args \
  -Pament.android_stl=$ANDROID_STL -Pament.android_abi=$ANDROID_ABI -Pament.android_ndk=$ANDROID_NDK -- $@
