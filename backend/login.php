<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$input = json_input();
$email = trim((string) ($input['email'] ?? ''));
$password = (string) ($input['password'] ?? '');

if ($email === '' || $password === '') {
    fail('Email and password are required.');
}

try {
    $pdo = db();
    $stmt = $pdo->prepare('SELECT * FROM Users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        fail('Invalid email or password.', 401);
    }

    $stored = (string) $user['password_hash'];
    $valid = password_verify($password, $stored) || hash_equals($stored, $password);

    if (!$valid) {
        fail('Invalid email or password.', 401);
    }

    $payload = current_user_payload($pdo, (int) $user['user_id']);
    if (!$payload) {
        fail('User profile was not found.', 404);
    }

    set_user_session($payload);
    respond(['success' => true, 'user' => $payload]);
} catch (Throwable $e) {
    fail('Login failed: ' . $e->getMessage(), 500);
}
