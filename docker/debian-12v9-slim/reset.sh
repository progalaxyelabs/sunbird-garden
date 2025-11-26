#!/bin/bash

SUNBIRD_IMAGE_NAME="sunbird:debian-slim12v9"

delete_old_image() {
    SUNBIRD_IMAGE_ID=$(docker images --format "{{.ID}}: {{.Repository}}" | grep sunbird | cut -c1-12)
    if [ -n "$SUNBIRD_IMAGE_ID" ]; then
        echo "deleting image $SUNBIRD_IMAGE_ID"
        docker rmi $SUNBIRD_IMAGE_ID
    else 
        echo "Image not found, skipping delete image"
    fi
}


build_new_image() {
    docker build --debug --progress=plain --no-cache-filter config -t $SUNBIRD_IMAGE_NAME .
    BUILD_STATUS=$?
    if [ $BUILD_STATUS -ne 0 ]; then
        echo "failed to build image"
        exit 1
    fi
}


start_container() {
    echo "starting containter.."
    # docker run -it --rm --pull=never -p "127.0.0.1:9100:80" -v ./apache2/srv/www.sunbird.local:/srv/www.sunbird.local --name=sunbird $SUNBIRD_IMAGE_NAME
    docker run -it --rm --pull=never -p "127.0.0.1:9100:80" --name=sunbird $SUNBIRD_IMAGE_NAME
}


if [ "$1" != "skipbuild" ]; then
    delete_old_image
    build_new_image
fi

start_container




