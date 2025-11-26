<?php

namespace App\DTO;

class GoogleSigninRequest
{
    public function __construct(
        public readonly string $googleToken,
    ) {}
}
