<?php

function log_cli($text) {
    $file_name = 'cli.log';
    $file_path = '/srv/www.sunbird.local/logs/';
    if(!file_exists($file_path . $file_name)) {
        $fp = fopen($file_path.$file_name, 'w+');
        fclose($fp);
        chmod($file_path.$file_name, 0644);
    }
    file_put_contents($file_path.$file_name, $text, FILE_APPEND);
}