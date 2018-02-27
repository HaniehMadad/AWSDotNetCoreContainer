#!/bin/sh

CONTAINER_NAME="demo"
IMAGE_NAME="demo"
IMAGE_VERSION="1.0"
CONTAINER_PORT="80"
HOST_PORT="8080"

#check if container already running
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]
then
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME -f status=running)" ]
    then
        echo "Stopping container '$CONTAINER_NAME'"
        docker stop $CONTAINER_NAME
    fi
    echo "Removing container '$CONTAINER_NAME'"
    docker rm $CONTAINER_NAME
else
    echo "Container '$CONTAINER_NAME' didn't exist"
fi

echo "Building docker image"
docker build -t $IMAGE_NAME:$IMAGE_VERSION ../.

echo "Running container ..."
docker run -d -p $HOST_PORT:$CONTAINER_PORT  --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_VERSION

#sleep for 2seconds before opening the browser
sleep 2

echo "browse to http://localhost:$HOST_PORT"
open http://localhost:$HOST_PORT
