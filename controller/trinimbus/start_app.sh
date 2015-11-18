#!/bin/bash

eval "$(docker-machine env --swarm swarm-master)"

# this will start 1 mysql node and 1 wordpress node
docker-compose --x-networking --x-network-driver overlay up -d 


# to add new node run this command. 
# docker run -d --net=bin -e WORDPRESS_DB_HOST=db -e WORDPRESS_DB_PASSWORD=example -p 80:80 wordpress
