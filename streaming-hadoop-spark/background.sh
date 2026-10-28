#!/bin/bash
set -e

mkdir -p /root/lab-streaming
mkdir -p /tmp/stream_dir

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python3-pip openjdk-11-jre-headless
pip3 install pyspark --no-cache-dir

touch /tmp/setup_finished