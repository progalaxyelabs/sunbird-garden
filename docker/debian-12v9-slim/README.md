# Docker Container to build Sunbird apps

there is a `reset.sh` script file to restart the docker build process whenever any changes were made to the project and the image needs to be rebuilt.

this script deletes the old image with the same name and builds a new image and starts the container.

to run commands inside the docker, you can use `docker exec`

apache server port 80 inside docker is mapped to host computer's port 9100. if you want to run multiple containers, use different ports in the `docker run` command.

you may copy the `docker run` command from the `reset.sh` script and make necessary alterations to volume mounts and port mappings before starting manually.

consider using `--rm` flag in `docker run` command when testing
