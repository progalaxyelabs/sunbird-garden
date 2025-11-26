#!/bin/bash -x
CONTAINER_ID=$(docker ps | grep sunbird | cut -c1-12)
docker exec -it $CONTAINER_ID bash