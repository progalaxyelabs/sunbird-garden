#!/bin/bash -x

if [ $# = 1 ]; then    
    SUNBIRD_ROOT_PATH=${SUNBIRD_ROOT_PATH:-"/srv/www.sunbird.local"}    
    cd "${SUNBIRD_ROOT_PATH}/public/apps"
    APP_DIR=$1
    mkdir "${APP_DIR}"
    php "${SUNBIRD_ROOT_PATH}/cli/file-templates/app-index-html.php" ${APP_DIR} > "${APP_DIR}/index.html"
else
    echo "incorrect number of arguments. usage: create-app.sh app_name"
fi

