<?php
declare(strict_types=1);
require_once __DIR__ . '/config.php';

$user = require_login();

if ($user['user_type'] !== 'employer' || !$user['employer_id']) {
    fail('Only employers can update jobs.', 403);
}

$employerId = (int) $user['employer_id'];
$input      = json_input();
$jobId      = isset($input['job_id']) ? (int) $input['job_id'] : 0;

if ($jobId <= 0) {
    fail('Invalid job_id.');
}

try {
    $pdo = db();

    // Verify ownership
    $check = $pdo->prepare('SELECT job_id FROM Jobs WHERE job_id = ? AND employer_id = ?');
    $check->execute([$jobId, $employerId]);
    if (!$check->fetch()) {
        fail('Job not found or you do not own it.', 403);
    }

    $allowed  = ['job_title', 'job_description', 'location', 'salary_range', 'status', 'application_limit'];
    $setClauses = [];
    $params     = [];

    foreach ($allowed as $field) {
        if (!array_key_exists($field, $input)) {
            continue;
        }
        if ($field === 'status' && !in_array($input[$field], ['open', 'closed'], true)) {
            fail('status must be "open" or "closed".');
        }
        if ($field === 'application_limit') {
            $val = (int) $input[$field];
            if ($val < 1) {
                fail('application_limit must be at least 1.');
            }
            $setClauses[] = "`$field` = ?";
            $params[]     = $val;
            continue;
        }
        $setClauses[] = "`$field` = ?";
        $params[]     = (string) $input[$field];
    }

    if (empty($setClauses)) {
        fail('No valid fields to update.');
    }

    $params[] = $jobId;
    $pdo->prepare('UPDATE Jobs SET ' . implode(', ', $setClauses) . ' WHERE job_id = ?')
        ->execute($params);

    respond(['success' => true, 'message' => 'Job updated.']);
} catch (Throwable $e) {
    fail('Could not update job: ' . $e->getMessage(), 500);
}
