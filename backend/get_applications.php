<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$user = require_login();
if (($user['user_type'] ?? '') !== 'candidate' || empty($user['candidate_id'])) {
    fail('Only candidates can view their applications.', 403);
}

try {
    $stmt = db()->prepare(
        "SELECT a.application_id, a.status, a.match_score, a.applied_at,
                j.job_id, j.job_title, j.location, j.salary_range,
                e.company_name,
                GROUP_CONCAT(DISTINCT CONCAT(s.skill_name, ':', s.category) ORDER BY js.weight DESC SEPARATOR '|') AS skills,
                MIN(i.interview_date) AS next_interview_date,
                MIN(i.interview_mode) AS next_interview_mode
         FROM Applications a
         INNER JOIN Jobs j ON j.job_id = a.job_id
         INNER JOIN Employers e ON e.employer_id = j.employer_id
         LEFT JOIN JobSkills js ON js.job_id = j.job_id
         LEFT JOIN Skills s ON s.skill_id = js.skill_id
         LEFT JOIN Interviews i ON i.application_id = a.application_id AND i.status = 'scheduled'
         WHERE a.candidate_id = ?
         GROUP BY a.application_id
         ORDER BY a.applied_at DESC"
    );
    $stmt->execute([(int) $user['candidate_id']]);

    $applications = [];
    foreach ($stmt->fetchAll() as $row) {
        $skills = [];
        if (!empty($row['skills'])) {
            foreach (explode('|', $row['skills']) as $skill) {
                [$name, $category] = array_pad(explode(':', $skill, 2), 2, 'default');
                $skills[] = ['name' => $name, 'category' => $category ?: 'default'];
            }
        }

        $applications[] = [
            'application_id' => (int) $row['application_id'],
            'status' => $row['status'],
            'match_score' => $row['match_score'] !== null ? (float) $row['match_score'] : null,
            'applied_at' => $row['applied_at'],
            'job_id' => (int) $row['job_id'],
            'job_title' => $row['job_title'],
            'location' => $row['location'],
            'salary_range' => $row['salary_range'],
            'company_name' => $row['company_name'],
            'skills' => $skills,
            'next_interview_date' => $row['next_interview_date'],
            'next_interview_mode' => $row['next_interview_mode'],
        ];
    }

    respond(['success' => true, 'applications' => $applications]);
} catch (Throwable $e) {
    fail('Could not load applications: ' . $e->getMessage(), 500);
}
