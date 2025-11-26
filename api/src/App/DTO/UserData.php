<?php

namespace App\DTO;

class UserData
{
    public function __construct(
        public readonly string $id,
        public readonly string $email,
        public readonly string $name,
        public readonly ?string $picture = null,
    ) {}
}
