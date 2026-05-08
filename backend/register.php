<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$input = json_input();
$role = (string) ($input['role'] ?? 'candidate');
$email = trim((string) ($input['email'] ?? ''));
$password = (string) ($input['password'] ?? '');
$name = trim((string) ($input['name'] ?? ''));
$phone = trim((string) ($input['phone'] ?? ''));
$companyDescription = trim((string) ($input['company_description'] ?? ''));

if (!in_array($role, ['candidate', 'employer'], true)) {
    fail('Invalid role.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    fail('A valid email is required.');
}
if (strlen($password) < 4) {
    fail('Password must be at least 4 characters.');
}
if ($name === '') {
    fail($role === 'employer' ? 'Company name is required.' : 'Full name is required.');
}

try {
    $pdo = db();
    $pdo->beginTransaction();

    $stmt = $pdo->prepare('INSERT INTO Users (email, password_hash, user_type) VALUES (?, ?, ?)');
    $stmt->execute([$email, password_hash($password, PASSWORD_DEFAULT), $role]);
    $userId = (int) $pdo->lastInsertId();

    if ($role === 'candidate') {
        $stmt = $pdo->prepare('INSERT INTO Candidates (user_id, full_name, phone) VALUES (?, ?, ?)');
        $stmt->execute([$userId, $name, $phone !== '' ? $phone : null]);
    } else {
        $stmt = $pdo->prepare('INSERT INTO Employers (user_id, company_name, company_description) VALUES (?, ?, ?)');
        $stmt->execute([$userId, $name, $companyDescription !== '' ? $companyDescription : null]);
    }

    $pdo->commit();

    $payload = current_user_payload($pdo, $userId);
    if (!$payload) {
        fail('Account created but profile could not be loaded.', 500);
    }

    set_user_session($payload);
    respond(['success' => true, 'user' => $payload], 201);
} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }

    if ($e->getCode() === '23000') {
        fail('That email is already registered.');
    }

    fail('Registration failed: ' . $e->getMessage(), 500);
}
