# Demo docker on multi host environment

### Prerequirement
* Docker installed
* VPC and subnet created on zone a and b.

### Dependency
* Docker image for consul:  progrium/consul [https://github.com/gliderlabs/docker-consul]
* AWS AMI: ami-677b6b06 [ubuntu 14.04 with Kernel 3.19]
* Official Docker image for swarm
* Official Docker image for MySql: https://hub.docker.com/_/mariadb/
* Official Docker image for Wordpress: https://hub.docker.com/_/wordpress/

### Build the image
This is not necessary, if the controller machine already have docker-machine, docker-compose installed.
```
docker build -t controller .
```

### Provision server and run application
* create the VPC and subnet.
* start the controller
```sh
docker run -it \
-e AWS_ACCESS_KEY_ID=xxx \
-e AWS_SECRET_ACCESS_KEY=xxx \
-e VPC_ID=xxx \
-v ~/.docker/machine:/machine-storage \
controller bash
```
* provision servers
```sh  
./provision_vm.sh 
```
* start the demo app (Wordpress+mysql)
```
./start_app.sh
```
* add more wordpress node to cluster
```
eval "$(docker-machine env --swarm swarm-master)"
docker-compose --x-networking --x-network-driver overlayer scale wordpress=3
```

### Notes:
* Docker libnetwork is released with Docker 1.9
* overlay driver is not support Linux Kernel <3.15, however docker-machine still using Ubuntu 14.04 LTS as the base image.
* Docker Swarm will spread the container accross all nodes by default. 
* docker-compose have some support to overlay network now.
* unfortunately due to a network issue, I cannot make it work in Trinimbus AWS account. But I have verified with my own AWS account.
