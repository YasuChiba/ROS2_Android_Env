#!/bin/bash

export ANDROID_NDK_VERSION=android-ndk-r21b
export ANDROID_SDK_VERSION=3859397 #6200805



function install_java() {
    apt-get update -qq
    apt-get install -y openjdk-8-jdk build-essential git
    apt-get install -y gradle locales
}

function setup_locale() {
    locale-gen en_US en_US.UTF-8
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
}

function setup_ros2_sources() {
    apt-get update && apt-get install -y curl gnupg2 lsb-release wget
    curl -sL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
    sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
}

function install_ros2_dependencies() {
    apt-get update && apt-get install -y python3-dev python3-pip
    apt-get install -y python3-colcon-common-extensions python3-vcstool python3-lark-parser
}

function install_colcon_extensions_for_gradle() {
    pip3 install git+git://github.com/colcon/colcon-gradle.git
    pip3 install git+git://github.com/colcon/colcon-ros-gradle.git
}

function install_android() {
    wget -O /tmp/android-ndk.zip https://dl.google.com/android/repository/${ANDROID_NDK_VERSION}-linux-x86_64.zip && mkdir -p /opt/android/ && cd /opt/android/ && unzip -q /tmp/android-ndk.zip && rm /tmp/android-ndk.zip
    wget -O /tmp/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && mkdir -p /opt/android/android-sdk-linux && cd /opt/android/android-sdk-linux && unzip -q /tmp/android-sdk.zip && rm /tmp/android-sdk.zip
    #wget -O /tmp/android-ndk.zip http://192.168.10.102:8000/android-ndk.zip && mkdir -p /opt/android/ && cd /opt/android/ && unzip -q /tmp/android-ndk.zip && rm /tmp/android-ndk.zip
    #wget -O /tmp/android-sdk.zip http://192.168.10.102:8000/android-sdk.zip && mkdir -p /opt/android/android-sdk-linux && cd /opt/android/android-sdk-linux && unzip -q /tmp/android-sdk.zip && rm /tmp/android-sdk.zip


    ANDROID_SDK=/opt/android/android-sdk-linux
    # Accept licenses
    yes | ${ANDROID_SDK}/tools/bin/sdkmanager --licenses
    # Install platform tools
    yes | ${ANDROID_SDK}/tools/bin/sdkmanager --verbose "platform-tools" "platforms;${ANDROID_TARGET}"
}

function setup_workspace() {
    mkdir -p /root/ros2_java_ws/src
    cd /root/ros2_java_ws
    curl -sL https://raw.githubusercontent.com/ros2-java/ros2_java/a3fa46df61aeee47d8bad5f0c7397d3f0f5da389/ros2_java_android.repos | vcs import src

    #これしないとJNI_VERSION_1_8が無いって起こられる。
    #これをするとJNI_VERSION_1_6が使われてるコードになる。めちゃくちゃアドホックなことしてるのでちょーーーっとヤダ。
    rm -rf src/ros2_java/ros2_java
    cd /root/ros2_java_ws/src/ros2_java
    git clone https://github.com/ros2-java/ros2_java.git
    cd ros2_java
    git checkout a3fa46df61aeee47d8bad5f0c7397d3f0f5da389

    cd /root/ros2_java_ws
}

function build_ros2java() {
    export PYTHON3_EXEC="$( which python3 )"
    export PYTHON3_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
    export PYTHON3_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"
    export ANDROID_ABI=armeabi-v7a
    export ANDROID_NATIVE_API_LEVEL=android-21
    export ANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-clang
    export ANDROID_NDK=/opt/android/${ANDROID_NDK_VERSION}
    #export ANDROID_HOME=/opt/android/android-sdk-linux
    #export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre

    cd /root/ros2_java_ws
    colcon build \
      --packages-ignore cyclonedds rcl_logging_log4cxx rosidl_generator_py \
      --packages-up-to rcljava \
      --cmake-args \
      -DPYTHON_EXECUTABLE=${PYTHON3_EXEC} \
      -DPYTHON_LIBRARY=${PYTHON3_LIBRARY} \
      -DPYTHON_INCLUDE_DIR=${PYTHON3_INCLUDE_DIR} \
      -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
      -DANDROID_FUNCTION_LEVEL_LINKING=OFF \
      -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL} \
      -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME} \
      -DANDROID_STL=c++_shared \
      -DANDROID_ABI=${ANDROID_ABI} \
      -DANDROID_NDK=${ANDROID_NDK} \
      -DTHIRDPARTY=ON \
      -DCOMPILE_EXAMPLES=OFF \
      -DCMAKE_FIND_ROOT_PATH="/root/ros2_java_ws/install;/root/ros2_java_ws/build"

}

install_java
setup_locale
setup_ros2_sources
install_ros2_dependencies
install_colcon_extensions_for_gradle
install_android
setup_workspace
build_ros2java


