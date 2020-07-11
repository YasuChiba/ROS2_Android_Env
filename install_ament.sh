#!/bin/sh
set -e

#amentのインストール

ROS2_HOME_DIR=/root
ROS2_OUTPUT_DIR=/root/output

AMENT_WS=${ROS2_HOME_DIR}/ament_ws
AMENT_BUILD_DIR=${ROS2_OUTPUT_DIR}/build_isolated_ament
AMENT_INSTALL_DIR=${ROS2_OUTPUT_DIR}/install_isolated_ament

mkdir -p ${AMENT_WS}/src

cd $AMENT_WS
wget https://raw.githubusercontent.com/esteve/ament_java/master/ament_java.repos

vcs import $AMENT_WS/src < ament_java.repos
$AMENT_WS/src/ament/ament_tools/scripts/ament.py build --parallel --isolated --install-space $AMENT_INSTALL_DIR --build-space $AMENT_BUILD_DIR
. $AMENT_INSTALL_DIR/local_setup.sh
