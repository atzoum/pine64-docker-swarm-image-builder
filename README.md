Description
===========
Simple Docker image which uses longsleep's scripts to build an Ubuntu Xenial image for pine64 with the appropriate kernel options enabled for docker swarm mode.


Usage
=====
    
    cd builder
    docker build -t pine64-docker-swarm-image-builder .
    docker run -ti -v /nfs/atlas/pine64-dev/workspace:/workspace --privileged pine64-docker-swarm-image-builder
