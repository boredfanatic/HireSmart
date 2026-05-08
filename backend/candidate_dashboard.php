<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$user = require_login();
if (($user['user_type'] ?? '') !== 'candidate' || empty($user['candidate_id'])) {
    fail('Only candidates can view this dashboard.', 403);
}

try {
    $pdo = db();
    $candidateId = (int) $user['candidate_id'];

    $stats = [
        'applications' => 0,
        'interviews' => 0,
        'avg_match' => 0,
        'skills' => 0,
    ];

    $stmt = $pdo->prepare(
        "SELECT COUNT(*) AS applications,
                SUM(status = 'interview_scheduled') AS interviews,
                ROUND(AVG(match_score), 0) AS avg_match
         FROM Applications
         WHERE candidate_id = ?"
    );
    $stmt->execute([$candidateId]);
    $row = $stmt->fetch() ?: [];
    $stats['applications'] = (int) ($row['applications'] ?? 0);
    $stats['interviews'] = (int) ($row['interviews'] ?? 0);
    $stats['avg_match'] = (int) ($row['avg_match'] ?? 0);

    $stmt = $pdo->prepare('SELECT COUNT(*) FROM CandidateSkills WHERE candidate_id = ?');
    $stmt->execute([$candidateId]);
    $stats['skills'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->prepare(
        "SELECT j.job_id, j.job_title, j.location, j.salary_range, e.company_name,
                CalculateMatchScore(?, j.job_id) AS match_score,
                GROUP_CONCAT(DISTINCT CONCAT(s.skill_name, ':', s.category) ORDER BY js.weight DESC SEPARATOR '|') AS skills
         FROM Jobs j
         INNER JOIN Employers e ON e.employer_id = j.employer_id
         LEFT JOIN JobSkills js ON js.job_id = j.job_id
         LEFT JOIN Skills s ON s.skill_id = js.skill_id
         WHERE j.status = 'open'
         GROUP BY j.job_id
         ORDER BY match_score DESC
         LIMIT 3"
    );
    $stmt->execute([$candidateId]);
    $matches = [];
    foreach ($stmt->fetchAll() as $row) {
        $skills = [];
        if (!empty($row['skills'])) {
            foreach (array_slice(explode('|', $row['skills']), 0, 4) as $skill) {
                [$name, $category] = array_pad(explode(':', $skill, 2), 2, 'default');
                $skills[] = ['name' => $name, 'category' => $category ?: 'default'];
            }
        }
        $matches[] = [
            'job_id' => (int) $row['job_id'],
            'job_title' => $row['job_title'],
            'company_name' => $row['company_name'],
            'location' => $row['location'],
            'salary_range' => $row['salary_range'],
            'match_score' => (float) $row['match_score'],
            'skills' => $skills,
        ];
    }

    $stmt = $pdo->prepare(
        "SELECT s.skill_name, s.category, cs.proficiency_level
         FROM CandidateSkills cs
         INNER JOIN Skills s ON s.skill_id = cs.skill_id
         WHERE cs.candidate_id = ?
         ORDER BY cs.proficiency_level DESC, s.skill_name"
    );
    $stmt->execute([$candidateId]);

    respond([
        'success' => true,
        'user' => current_user_payload($pdo, (int) $user['user_id']),
        'stats' => $stats,
        'matches' => $matches,
        'skills' => $stmt->fetchAll(),
    ]);
} catch (Throwable $e) {
    fail('Could not load dashboard: ' . $e->getMessage(), 500);
}
