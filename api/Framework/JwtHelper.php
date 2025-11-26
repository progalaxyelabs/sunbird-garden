<?php

namespace Framework;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHelper
{
    private static function getSecretKey(): string
    {
        $secret = Env::get('JWT_SECRET');
        if (!$secret) {
            throw new \Exception('JWT_SECRET not configured in environment');
        }
        return $secret;
    }

    /**
     * Generate a JWT token for a user
     *
     * @param array $userData User data to encode in the token
     * @param int $expiresIn Expiration time in seconds (default: 7 days)
     * @return string JWT token
     */
    public static function generateToken(array $userData, int $expiresIn = 604800): string
    {
        $issuedAt = time();
        $expire = $issuedAt + $expiresIn;

        $payload = [
            'iat' => $issuedAt,
            'exp' => $expire,
            'user' => $userData
        ];

        return JWT::encode($payload, self::getSecretKey(), 'HS256');
    }

    /**
     * Verify and decode a JWT token
     *
     * @param string $token JWT token to verify
     * @return object Decoded token payload
     * @throws \Exception if token is invalid or expired
     */
    public static function verifyToken(string $token): object
    {
        try {
            return JWT::decode($token, new Key(self::getSecretKey(), 'HS256'));
        } catch (\Exception $e) {
            throw new \Exception('Invalid or expired token: ' . $e->getMessage());
        }
    }

    /**
     * Extract user data from a JWT token
     *
     * @param string $token JWT token
     * @return array User data from token
     */
    public static function getUserFromToken(string $token): array
    {
        $decoded = self::verifyToken($token);
        return (array) $decoded->user;
    }

    /**
     * Get authorization token from request headers
     *
     * @return string|null Token if present, null otherwise
     */
    public static function getTokenFromHeaders(): ?string
    {
        $headers = getallheaders();

        // Check for Authorization header
        if (isset($headers['Authorization'])) {
            $auth = $headers['Authorization'];
            // Remove "Bearer " prefix if present
            if (strpos($auth, 'Bearer ') === 0) {
                return substr($auth, 7);
            }
            return $auth;
        }

        return null;
    }
}
