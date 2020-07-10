#!/bin/bash

export GOGS_URL="http://1.1.2.3:2048"
export DRONE_HOST="0.0.0.0"
export DRONE_SECRET="xh1HJLO2yfandlwjeHdsL3Kklwheour89"
export DOCKER_HOST="tcp://$(docker network inspect --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge):2375"

docker run -d \
    --volume=/var/lib/drone:/data \
    --env=DRONE_GOGS_SERVER=${GOGS_URL} \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --env=DRONE_SERVER_HOST=${DRONE_HOST} \
    --env=DRONE_SERVER_PROTO=http \
    --publish=3005:80 \
    --restart=always \
    --name=drone \
    drone/drone

docker run -d \
    --env=DOCKER_HOST=${DOCKER_HOST} \
    --env=DRONE_RPC_SERVER=http://drone-server \
    --env=DRONE_RPC_SECRET=${DRONE_SECRET} \
    --restart=always \
    --name=drone-agent \
    --link drone:drone-server \
    drone/agent

docker run -d \
    -e DRONE_RPC_HOST=drone-server \
    -e DRONE_RPC_SECRET=${DRONE_SECRET} \
    --restart always \
    --name runner \
    --link drone:drone-server \
    drone/drone-runner-ssh
