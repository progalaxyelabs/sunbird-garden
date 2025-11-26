<?php

namespace App\DTO;

class GoogleSigninResponse
{
    public function __construct(
        public readonly string $token,
        public readonly UserData $user,
    ) {}
}
