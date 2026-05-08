<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$user = require_login();
if (($user['user_type'] ?? '') !== 'employer' || empty($user['employer_id'])) {
    fail('Only employers can update application status.', 403);
}

$input = json_input();
$applicationId = (int) ($input['application_id'] ?? 0);
$status = trim((string) ($input['status'] ?? ''));

$allowed = ['pending', 'shortlisted', 'rejected', 'interview_scheduled'];
if (!$applicationId || !in_array($status, $allowed, true)) {
    fail('Invalid application_id or status.');
}

try {
    $pdo = db();

    $stmt = $pdo->prepare(
        "SELECT a.application_id, c.user_id AS candidate_user_id, j.job_title
         FROM Applications a
         INNER JOIN Jobs j ON j.job_id = a.job_id
         INNER JOIN Candidates c ON c.candidate_id = a.candidate_id
         WHERE a.application_id = ? AND j.employer_id = ?"
    );
    $stmt->execute([$applicationId, (int) $user['employer_id']]);
    $row = $stmt->fetch();

    if (!$row) {
        fail('Application not found or access denied.', 404);
    }

    $pdo->prepare('CALL UpdateApplicationStatus(?, ?)')->execute([$applicationId, $status]);

    $labels = [
        'shortlisted'          => 'shortlisted for',
        'rejected'             => 'not selected for',
        'interview_scheduled'  => 'scheduled for an interview for',
    ];
    if (isset($labels[$status])) {
        create_notification(
            $pdo,
            (int) $row['candidate_user_id'],
            "Your application has been {$labels[$status]} {$row['job_title']}."
        );
    }

    respond(['success' => true]);
} catch (Throwable $e) {
    fail('Could not update status: ' . $e->getMessage(), 500);
}
