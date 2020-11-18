#!/bin/sh
set -e
SCRIPT_DIR=$(cd $(dirname $0); pwd)


apt -y update 
apt -y upgrade

apt install -y git vim cmake build-essential python3 python3-pip openjdk-8-jdk
apt install -y unzip wget gradle

cd /usr/bin
ln -s /usr/bin/python3.6 ./python 

cd $SCRIPT_DIR
pip3 install vcstool catkin-pkg empy


$SCRIPT_DIR/install_android_env.sh
$SCRIPT_DIR/install_ament.sh
$SCRIPT_DIR/install_ros2_java.sh
$SCRIPT_DIR/install_micro_xrce_dds.sh
