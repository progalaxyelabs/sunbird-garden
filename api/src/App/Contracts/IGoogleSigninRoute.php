<?php

namespace App\Contracts;

use App\DTO\GoogleSigninRequest;
use App\DTO\GoogleSigninResponse;

interface IGoogleSigninRoute
{
    public function execute(GoogleSigninRequest $request): GoogleSigninResponse;
}
