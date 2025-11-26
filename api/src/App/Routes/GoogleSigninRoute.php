<?php

namespace App\Routes;

use Framework\IRouteHandler;
use Framework\ApiResponse;
use Framework\Database;
use Framework\JwtHelper;
use App\Contracts\IGoogleSigninRoute;
use App\DTO\GoogleSigninRequest;
use App\DTO\GoogleSigninResponse;
use App\DTO\UserData;

class GoogleSigninRoute implements IRouteHandler, IGoogleSigninRoute
{
    public string $googleToken;

    public function validation_rules(): array
    {
        return [
            'googleToken' => 'required|min:10',
        ];
    }

    public function process(): ApiResponse
    {
        $request = new GoogleSigninRequest(
            googleToken: $this->googleToken
        );

        try {
            $response = $this->execute($request);
            return res_ok($response, 'Sign in successful');
        } catch (\Exception $e) {
            return res_error($e->getMessage(), 401);
        }
    }

    public function execute(GoogleSigninRequest $request): GoogleSigninResponse
    {
        // Verify Google token
        $googleUser = $this->verifyGoogleToken($request->googleToken);

        if (!$googleUser) {
            throw new \Exception('Invalid Google token');
        }

        // Get or create user in database
        $user = $this->getOrCreateUser($googleUser);

        // Generate JWT token
        $jwtToken = JwtHelper::generateToken([
            'id' => $user['id'],
            'email' => $user['email'],
            'name' => $user['name'],
            'picture' => $user['picture'] ?? null,
        ]);

        // Return response
        return new GoogleSigninResponse(
            token: $jwtToken,
            user: new UserData(
                id: $user['id'],
                email: $user['email'],
                name: $user['name'],
                picture: $user['picture'] ?? null
            )
        );
    }

    private function verifyGoogleToken(string $token): ?array
    {
        try {
            $client = new \Google_Client(['client_id' => $this->getGoogleClientId()]);
            $payload = $client->verifyIdToken($token);

            if ($payload) {
                return [
                    'google_id' => $payload['sub'],
                    'email' => $payload['email'],
                    'name' => $payload['name'] ?? $payload['email'],
                    'picture' => $payload['picture'] ?? null,
                ];
            }

            return null;
        } catch (\Exception $e) {
            error_log('Google token verification failed: ' . $e->getMessage());
            return null;
        }
    }

    private function getGoogleClientId(): string
    {
        // Get from environment or use the one from frontend config
        return '108864518050-fjhjlifc56klj8rsmm4r9tmn9p7j632d.apps.googleusercontent.com';
    }

    private function getOrCreateUser(array $googleUser): array
    {
        $db = Database::getConnection();

        // Try to find existing user by google_id
        $stmt = $db->prepare('
            SELECT id, google_id, email, name, picture
            FROM users
            WHERE google_id = :google_id
        ');
        $stmt->execute(['google_id' => $googleUser['google_id']]);
        $user = $stmt->fetch(\PDO::FETCH_ASSOC);

        if ($user) {
            // Update last login and potentially updated info
            $stmt = $db->prepare('
                UPDATE users
                SET name = :name,
                    picture = :picture,
                    last_login = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = :id
                RETURNING id, google_id, email, name, picture
            ');
            $stmt->execute([
                'id' => $user['id'],
                'name' => $googleUser['name'],
                'picture' => $googleUser['picture'],
            ]);
            return $stmt->fetch(\PDO::FETCH_ASSOC);
        }

        // Create new user
        $stmt = $db->prepare('
            INSERT INTO users (google_id, email, name, picture, last_login)
            VALUES (:google_id, :email, :name, :picture, CURRENT_TIMESTAMP)
            RETURNING id, google_id, email, name, picture
        ');
        $stmt->execute([
            'google_id' => $googleUser['google_id'],
            'email' => $googleUser['email'],
            'name' => $googleUser['name'],
            'picture' => $googleUser['picture'],
        ]);

        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }
}
