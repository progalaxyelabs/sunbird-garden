<?php

$url = $_SERVER['REQUEST_URI'];

$routes = [
    '/' => 'home',
    '/create-organization' => 'create-organization',
    '/create-app' => 'create-app'
];

$filename = isset($routes[$url]) ? $routes[$url] : '404';
$request_method = strtolower($_SERVER['REQUEST_METHOD']);
$route = realpath(__DIR__ . "/../routes/$request_method/$filename.php");
$f404 = realpath(__DIR__ . "/../routes/get/404.php");

include '../helpers/log.php';
include '../helpers/view.php';


if (file_exists($route)) {
    include $route;
} else {
    include $f404;
}

echo print_r([$filename, $route, $f404], true);