<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$user = require_login();
if (($user['user_type'] ?? '') !== 'employer' || empty($user['employer_id'])) {
    fail('Only employers can view this dashboard.', 403);
}

try {
    $pdo = db();
    $employerId = (int) $user['employer_id'];

    $stmt = $pdo->prepare(
        "SELECT COUNT(*) AS active_jobs
         FROM Jobs
         WHERE employer_id = ? AND status = 'open'"
    );
    $stmt->execute([$employerId]);
    $activeJobs = (int) $stmt->fetchColumn();

    $stmt = $pdo->prepare(
        "SELECT COUNT(a.application_id) AS applicants,
                SUM(a.status = 'shortlisted') AS shortlisted,
                SUM(a.status = 'interview_scheduled') AS interviews
         FROM Jobs j
         LEFT JOIN Applications a ON a.job_id = j.job_id
         WHERE j.employer_id = ?"
    );
    $stmt->execute([$employerId]);
    $row = $stmt->fetch() ?: [];

    $stmt = $pdo->prepare(
        "SELECT a.application_id, a.match_score, a.status, j.job_title,
                c.full_name, u.email, c.user_id AS candidate_user_id,
                (SELECT i.interview_id   FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_id,
                (SELECT i.interview_date FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_date,
                (SELECT i.interview_mode FROM Interviews i WHERE i.application_id = a.application_id ORDER BY i.created_at DESC LIMIT 1) AS interview_mode
         FROM Applications a
         INNER JOIN Jobs j ON j.job_id = a.job_id
         INNER JOIN Candidates c ON c.candidate_id = a.candidate_id
         INNER JOIN Users u ON u.user_id = c.user_id
         WHERE j.employer_id = ?
         ORDER BY a.match_score DESC
         LIMIT 8"
    );
    $stmt->execute([$employerId]);
    $candidates = $stmt->fetchAll();

    $stmt = $pdo->prepare(
        "SELECT j.job_id, j.job_title, j.status, j.application_limit, j.location,
                COUNT(a.application_id) AS total_applicants
         FROM Jobs j
         LEFT JOIN Applications a ON a.job_id = j.job_id
         WHERE j.employer_id = ?
         GROUP BY j.job_id
         ORDER BY j.created_at DESC"
    );
    $stmt->execute([$employerId]);
    $jobs = $stmt->fetchAll();

    respond([
        'success' => true,
        'user' => current_user_payload($pdo, (int) $user['user_id']),
        'stats' => [
            'active_jobs' => $activeJobs,
            'applicants' => (int) ($row['applicants'] ?? 0),
            'shortlisted' => (int) ($row['shortlisted'] ?? 0),
            'interviews' => (int) ($row['interviews'] ?? 0),
        ],
        'candidates' => $candidates,
        'jobs' => $jobs,
    ]);
} catch (Throwable $e) {
    fail('Could not load dashboard: ' . $e->getMessage(), 500);
}
