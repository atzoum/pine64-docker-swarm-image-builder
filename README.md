Description
===========
Simple Docker image which uses longsleep's scripts to build an Ubuntu Xenial image for pine64 with the appropriate kernel options enabled for docker swarm mode.


Usage
=====
    
    mkdir workspace
    docker build -t pine64-image-builder builder/ && \
      docker run --privileged --rm -t -v ${pwd}/workspace:/workspace pine64-image-builder
