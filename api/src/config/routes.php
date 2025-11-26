<?php

use App\Routes\HomeRoute;
use App\Routes\GoogleSigninRoute;
use App\Routes\WebsitesRoute;

return [
    'GET' => [
        '/' => HomeRoute::class,
    ],
    'POST' => [
        '/websites' => WebsitesRoute::class,
        '/auth/google-signin' => GoogleSigninRoute::class,
    ]
];
