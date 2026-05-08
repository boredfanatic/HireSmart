<?php
declare(strict_types=1);
require_once __DIR__ . '/config.php';

$user = require_login();

if ($user['user_type'] !== 'employer' || !$user['employer_id']) {
    fail('Only employers can access this endpoint.', 403);
}

$employerId = (int) $user['employer_id'];

try {
    $pdo  = db();
    $stmt = $pdo->prepare(
        "SELECT j.job_id, j.job_title, j.job_description, j.location, j.salary_range,
                j.status, j.application_limit, j.created_at,
                e.company_name,
                COUNT(DISTINCT a.application_id) AS total_applicants,
                GROUP_CONCAT(DISTINCT CONCAT(s.skill_name, ':', s.category) ORDER BY js.weight DESC SEPARATOR '|') AS skills
         FROM Jobs j
         INNER JOIN Employers e ON e.employer_id = j.employer_id
         LEFT  JOIN Applications a  ON a.job_id  = j.job_id
         LEFT  JOIN JobSkills js    ON js.job_id = j.job_id
         LEFT  JOIN Skills s        ON s.skill_id = js.skill_id
         WHERE j.employer_id = ?
         GROUP BY j.job_id, e.company_name
         ORDER BY j.created_at DESC"
    );
    $stmt->execute([$employerId]);

    $jobs = [];
    foreach ($stmt->fetchAll() as $row) {
        $skills = [];
        if (!empty($row['skills'])) {
            foreach (explode('|', $row['skills']) as $skill) {
                [$name, $category] = array_pad(explode(':', $skill, 2), 2, 'default');
                $skills[] = ['name' => $name, 'category' => $category ?: 'default'];
            }
        }

        $jobs[] = [
            'job_id'            => (int) $row['job_id'],
            'job_title'         => $row['job_title'],
            'job_description'   => $row['job_description'],
            'location'          => $row['location'],
            'salary_range'      => $row['salary_range'],
            'status'            => $row['status'],
            'application_limit' => (int) $row['application_limit'],
            'created_at'        => $row['created_at'],
            'company_name'      => $row['company_name'],
            'total_applicants'  => (int) $row['total_applicants'],
            'skills'            => $skills,
        ];
    }

    respond(['success' => true, 'jobs' => $jobs]);
} catch (Throwable $e) {
    fail('Could not load jobs: ' . $e->getMessage(), 500);
}
