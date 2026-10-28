#!/bin/bash

# Redirigir logs a un archivo para poder auditar cualquier detalle si es necesario
exec > /var/log/killercoda-background.log 2>&1

mkdir -p /root/lab-streaming
mkdir -p /tmp/stream_dir

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python3-pip default-jre-headless

# En Ubuntu 24.04 (Python 3.12+) se requiere --break-system-packages (PEP 668)
pip3 install pyspark --no-cache-dir --break-system-packages

# Señalizar finalización para desbloquear foreground.sh
touch /tmp/setup_finished