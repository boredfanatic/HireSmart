<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$user = require_login();
if (($user['user_type'] ?? '') !== 'employer' || empty($user['employer_id'])) {
    fail('Only employers can view candidates.', 403);
}

try {
    $pdo = db();
    $employerId = (int) $user['employer_id'];

    $stmt = $pdo->prepare(
        "SELECT a.application_id, a.match_score, a.status, a.applied_at,
                j.job_title, j.job_id,
                c.full_name, u.email, c.user_id AS candidate_user_id,
                (SELECT i.interview_id   FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_id,
                (SELECT i.interview_date FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_date,
                (SELECT i.interview_mode FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_mode
         FROM Applications a
         INNER JOIN Jobs j ON j.job_id = a.job_id
         INNER JOIN Candidates c ON c.candidate_id = a.candidate_id
         INNER JOIN Users u ON u.user_id = c.user_id
         WHERE j.employer_id = ?
         ORDER BY a.match_score DESC, a.applied_at DESC"
    );
    $stmt->execute([$employerId]);
    $candidates = $stmt->fetchAll();

    respond(['success' => true, 'candidates' => $candidates]);
} catch (Throwable $e) {
    fail('Could not load candidates: ' . $e->getMessage(), 500);
}
