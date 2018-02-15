#!/bin/sh

CONTAINER_NAME="test1"
IMAGE_NAME="test1"
IMAGE_VERSION="1.0"
CONTAINER_PORT="80"
HOST_PORT="8080"

#check if container already running
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]
then
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME -f status=running)" ]
    then
        docker stop $CONTAINER_NAME
    fi
    docker rm $CONTAINER_NAME
else
    echo "test20"
fi

docker run -d -p $HOST_PORT:$CONTAINER_PORT  --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_VERSION

#sleep for 2seconds before opening the browser
sleep 2

open http://localhost:$HOST_PORT
