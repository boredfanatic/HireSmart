<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

try {
    $pdo = db();
    $user = $_SESSION['user'] ?? null;
    $candidateId = $user['candidate_id'] ?? null;

    $stmt = $pdo->prepare(
        "SELECT j.job_id, j.job_title, j.job_description, j.location, j.salary_range,
                j.status, j.application_limit, j.created_at,
                e.company_name,
                COUNT(DISTINCT a.application_id) AS total_applicants,
                GROUP_CONCAT(DISTINCT CONCAT(s.skill_name, ':', s.category) ORDER BY js.weight DESC SEPARATOR '|') AS skills,
                CASE WHEN ? IS NULL THEN NULL
                     ELSE CalculateMatchScore(?, j.job_id)
                END AS match_score,
                CASE WHEN ? IS NULL THEN 0
                     ELSE EXISTS (
                         SELECT 1 FROM Applications ax
                         WHERE ax.job_id = j.job_id AND ax.candidate_id = ?
                     )
                END AS already_applied
         FROM Jobs j
         INNER JOIN Employers e ON e.employer_id = j.employer_id
         LEFT JOIN Applications a ON a.job_id = j.job_id
         LEFT JOIN JobSkills js ON js.job_id = j.job_id
         LEFT JOIN Skills s ON s.skill_id = js.skill_id
         WHERE j.status = 'open'
         GROUP BY j.job_id, e.company_name
         ORDER BY COALESCE(match_score, 0) DESC, j.created_at DESC"
    );
    $stmt->execute([$candidateId, $candidateId, $candidateId, $candidateId]);
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
            'job_id' => (int) $row['job_id'],
            'job_title' => $row['job_title'],
            'job_description' => $row['job_description'],
            'location' => $row['location'],
            'salary_range' => $row['salary_range'],
            'status' => $row['status'],
            'created_at' => $row['created_at'],
            'company_name' => $row['company_name'],
            'total_applicants' => (int) $row['total_applicants'],
            'skills' => $skills,
            'match_score' => $row['match_score'] !== null ? (float) $row['match_score'] : null,
            'already_applied' => (bool) $row['already_applied'],
        ];
    }

    respond(['success' => true, 'jobs' => $jobs]);
} catch (Throwable $e) {
    fail('Could not load jobs: ' . $e->getMessage(), 500);
}
