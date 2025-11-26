<?php

function view($filename, $data = []) {
    ob_start();
    extract($data);
    include "../views/$filename";
    $output = ob_get_clean();
    echo $output;
}