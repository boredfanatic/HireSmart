<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$user = require_login();
if (($user['user_type'] ?? '') !== 'candidate' || empty($user['candidate_id'])) {
    fail('Only candidates can apply for jobs.', 403);
}

$input = json_input();
$jobId = (int) ($input['job_id'] ?? 0);
if ($jobId <= 0) {
    fail('A valid job_id is required.');
}

try {
    $pdo = db();
    $stmt = $pdo->prepare('CALL ApplyForJob(?, ?)');
    $stmt->execute([$jobId, (int) $user['candidate_id']]);
    $stmt->closeCursor();

    respond(['success' => true, 'message' => 'Application submitted.']);
} catch (PDOException $e) {
    fail($e->getMessage(), 400);
}
