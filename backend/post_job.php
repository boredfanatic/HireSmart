<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$user = require_login();
if (($user['user_type'] ?? '') !== 'employer' || empty($user['employer_id'])) {
    fail('Only employers can post jobs.', 403);
}

$input = json_input();
$title = trim((string) ($input['job_title'] ?? ''));
$location = trim((string) ($input['location'] ?? ''));
$salary = trim((string) ($input['salary_range'] ?? ''));
$description = trim((string) ($input['job_description'] ?? ''));
$skillsRaw = (string) ($input['skills'] ?? '');

if ($title === '') {
    fail('Job title is required.');
}

try {
    $pdo = db();
    $pdo->beginTransaction();

    $stmt = $pdo->prepare(
        "INSERT INTO Jobs (employer_id, job_title, job_description, location, salary_range)
         VALUES (?, ?, ?, ?, ?)"
    );
    $stmt->execute([
        (int) $user['employer_id'],
        $title,
        $description !== '' ? $description : null,
        $location !== '' ? $location : null,
        $salary !== '' ? $salary : null,
    ]);
    $jobId = (int) $pdo->lastInsertId();

    $skills = array_filter(array_map('trim', explode(',', $skillsRaw)));
    foreach ($skills as $skillName) {
        $stmt = $pdo->prepare('SELECT skill_id FROM Skills WHERE LOWER(skill_name) = LOWER(?) LIMIT 1');
        $stmt->execute([$skillName]);
        $skillId = $stmt->fetchColumn();

        if (!$skillId) {
            $stmt = $pdo->prepare('INSERT INTO Skills (skill_name, category) VALUES (?, ?)');
            $stmt->execute([$skillName, 'tools']);
            $skillId = $pdo->lastInsertId();
        }

        $stmt = $pdo->prepare('INSERT IGNORE INTO JobSkills (job_id, skill_id, weight) VALUES (?, ?, 7)');
        $stmt->execute([$jobId, (int) $skillId]);
    }

    $pdo->commit();
    respond(['success' => true, 'job_id' => $jobId], 201);
} catch (Throwable $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    fail('Could not post job: ' . $e->getMessage(), 500);
}
