#!/bin/bash

SUNBIRD_IMAGE_ID=$(docker images --format "{{.ID}}: {{.Repository}}" | grep sunbird | cut -c1-12)
if [ -n "$SUNBIRD_IMAGE_ID" ]; then
    echo "deleting image $SUNBIRD_IMAGE_ID"
    docker rmi $SUNBIRD_IMAGE_ID
else 
    echo "Image not found, skipping delete image"
fi

docker build --debug -t "sunbird:1.0" .

BUILD_STATUS=$?

# echo "result of previous command is $BUILD_STATUS"
if [ $BUILD_STATUS -ne 0 ]; then
    echo "failed to build image"
else
    echo "starting containter.."
    docker run -it --rm --pull=never -p "127.0.0.1:9100:80" -v .:/home/www-data/projects sunbird:1.0
fi