#!/bin/sh

IMAGE_TAG="test1"
IMAGE_VERSION="1.0"

docker build -t $IMAGE_TAG:$IMAGE_VERSION ../