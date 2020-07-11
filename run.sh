#!/bin/sh
set -e


apt -y update 
apt -y upgrade

apt install -y git vim cmake build-essential python3 python3-pip openjdk-8-jdk unzip wget

cd /usr/bin
ln -s /usr/bin/python3.6 ./python 
cd ~/Env_test

pip3 install vcstool catkin-pkg empy


./install_android_env.sh
./install_ament.sh
./install_ros2_java.sh
./install_micro_xrce_dds.sh