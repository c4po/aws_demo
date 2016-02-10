#!/bin/bash

#AWS_ACCESS_KEY_ID=
#AWS_SECRET_ACCESS_KEY=
#VPC_ID=
BASE_IMAGE=ami-677b6b06
# This image is a ubuntu 14.04 with 3.19 kernel
# There is a bug with docker network that cannot support Linux kernel < 3.15

# Creating Consul Server

docker-machine create --driver amazonec2 \
--amazonec2-access-key ${AWS_ACCESS_KEY_ID} --amazonec2-secret-key ${AWS_SECRET_ACCESS_KEY} \
--amazonec2-region us-east-1 \
--amazonec2-ami ${BASE_IMAGE} \
--amazonec2-vpc-id ${VPC_ID} consul

# Start Consul with single node
docker $(docker-machine config consul) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

# Create the swarm master server
docker-machine create --driver amazonec2 \
--swarm --swarm-master --swarm-image="swarm:1.0.0" \
--swarm-discovery="consul://$(docker-machine ip consul):8500" \
--amazonec2-access-key ${AWS_ACCESS_KEY_ID} --amazonec2-secret-key ${AWS_SECRET_ACCESS_KEY} \
--amazonec2-region us-east-1 --amazonec2-zone a \
--amazonec2-vpc-id ${VPC_ID} \
--amazonec2-ami ${BASE_IMAGE} \
--engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
--engine-opt="cluster-advertise=eth0:2376" \
swarm-master

# Create swarm node
docker-machine create --driver amazonec2 \
--swarm --swarm-image="swarm:1.0.0" \
--swarm-discovery="consul://$(docker-machine ip consul):8500" \
--amazonec2-access-key $AWS_ACCESS_KEY_ID --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY \
--amazonec2-region us-east-1  --amazonec2-zone a \
--amazonec2-vpc-id ${VPC_ID} \
--amazonec2-ami ${BASE_IMAGE} \
--engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
--engine-opt="cluster-advertise=eth0:2376" \
swarm-node1

# Create swarm node in different zone
docker-machine create --driver amazonec2 \
--swarm --swarm-image="swarm:1.0.0" \
--swarm-discovery="consul://$(docker-machine ip consul):8500" \
--amazonec2-access-key $AWS_ACCESS_KEY_ID --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY \
--amazonec2-region us-east-1  --amazonec2-zone b \
--amazonec2-vpc-id ${VPC_ID} \
--amazonec2-ami ${BASE_IMAGE} \
--engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
--engine-opt="cluster-advertise=eth0:2376" \
swarm-node2
