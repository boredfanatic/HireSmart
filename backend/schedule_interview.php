<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    fail('POST required.', 405);
}

$user = require_login();
if (($user['user_type'] ?? '') !== 'employer' || empty($user['employer_id'])) {
    fail('Only employers can schedule interviews.', 403);
}

$input = json_input();
$applicationId = (int) ($input['application_id'] ?? 0);
$interviewDate  = trim((string) ($input['interview_date'] ?? ''));
$interviewMode  = trim((string) ($input['interview_mode'] ?? 'online'));
$interviewId    = isset($input['interview_id']) && $input['interview_id'] !== '' ? (int) $input['interview_id'] : null;

if (!$applicationId || !$interviewDate) {
    fail('application_id and interview_date are required.');
}

$allowedModes = ['online', 'in_person'];
if (!in_array($interviewMode, $allowedModes, true)) {
    fail('interview_mode must be online or in_person.');
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

    $formattedDate = date('M j, Y g:i A', strtotime($interviewDate));

    if ($interviewId) {
        $pdo->prepare(
            'UPDATE Interviews SET interview_date = ?, interview_mode = ?
             WHERE interview_id = ? AND application_id = ?'
        )->execute([$interviewDate, $interviewMode, $interviewId, $applicationId]);

        $message = "Your interview for {$row['job_title']} has been rescheduled to {$formattedDate}.";
    } else {
        $stmt = $pdo->prepare(
            'SELECT COALESCE(MAX(round_number), 0) + 1 FROM Interviews WHERE application_id = ?'
        );
        $stmt->execute([$applicationId]);
        $nextRound = (int) $stmt->fetchColumn();

        $pdo->prepare('CALL ScheduleInterview(?, ?, ?, ?, NULL)')
            ->execute([$applicationId, $nextRound, $interviewDate, $interviewMode]);

        $message = "You have been scheduled for an interview for {$row['job_title']} on {$formattedDate}.";
    }

    create_notification($pdo, (int) $row['candidate_user_id'], $message);

    respond(['success' => true]);
} catch (Throwable $e) {
    fail('Could not schedule interview: ' . $e->getMessage(), 500);
}
