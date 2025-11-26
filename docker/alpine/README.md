## To run the container, execute `reset.sh` script

$ `./reset.sh`

This reset.sh script removes any existing image, rebuilds the image and starts a container using the following command.

`docker run -it --rm --pull=never -p "127.0.0.1:9100:80" -v .:/home/www-data/projects sunbird:1.0`

Note: If there is a container already created using this image, then deleting the image will fail.