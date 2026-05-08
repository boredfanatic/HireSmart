<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$user  = require_login();
$input = json_input();

try {
    $pdo    = db();
    $userId = (int) $user['user_id'];

    if ($user['user_type'] === 'employer') {
        $companyName = trim((string) ($input['company_name'] ?? ''));
        $companyDesc = trim((string) ($input['company_description'] ?? ''));

        if ($companyName === '') {
            fail('Company name is required.');
        }

        $pdo->prepare(
            'UPDATE Employers SET company_name = ?, company_description = ? WHERE user_id = ?'
        )->execute([$companyName, $companyDesc !== '' ? $companyDesc : null, $userId]);
    } else {
        $fullName = trim((string) ($input['full_name'] ?? ''));
        $phone    = trim((string) ($input['phone'] ?? ''));

        if ($fullName === '') {
            fail('Full name is required.');
        }

        $pdo->prepare(
            'UPDATE Candidates SET full_name = ?, phone = ? WHERE user_id = ?'
        )->execute([$fullName, $phone !== '' ? $phone : null, $userId]);
    }

    $updated = current_user_payload($pdo, $userId);
    set_user_session($updated);

    respond(['success' => true, 'user' => $updated]);
} catch (Throwable $e) {
    fail('Could not update profile: ' . $e->getMessage(), 500);
}
