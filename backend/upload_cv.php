<?php
declare(strict_types=1);
require_once 'config.php';

$user   = require_login();
$action = $_POST['action'] ?? 'parse';

$projectRoot = dirname(__DIR__);
$userId      = (int) $user['user_id'];
$pdfRelPath  = "data/uploads/resume_{$userId}.pdf";
$jsonRelPath = "data/parsed_cv_{$userId}.json";

if ($action === 'parse') {

    if (!isset($_FILES['cv']) || $_FILES['cv']['error'] !== UPLOAD_ERR_OK) {
        fail('No file uploaded or upload error.');
    }

    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime  = $finfo->file($_FILES['cv']['tmp_name']);
    if ($mime !== 'application/pdf') {
        fail('Only PDF files are accepted.');
    }

    $uploadsDir = $projectRoot . DIRECTORY_SEPARATOR . 'data' . DIRECTORY_SEPARATOR . 'uploads';
    if (!is_dir($uploadsDir)) {
        mkdir($uploadsDir, 0755, true);
    }

    $dest = $projectRoot . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $pdfRelPath);
    if (!move_uploaded_file($_FILES['cv']['tmp_name'], $dest)) {
        fail('Failed to save uploaded file.');
    }

    // Run cv_parser.py from the project root so its relative paths resolve correctly.
    // On Windows XAMPP use 'python'; change to 'python3' if needed.
    chdir($projectRoot);
    $cmd = 'python python/cv_parser.py ' . escapeshellarg($pdfRelPath) . ' ' . escapeshellarg($jsonRelPath) . ' 2>&1';
    exec($cmd, $output, $code);

    if ($code !== 0) {
        fail('CV parsing failed: ' . implode(' | ', $output));
    }

    $parsedPath = $projectRoot . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $jsonRelPath);
    if (!file_exists($parsedPath)) {
        fail('Parser produced no output. Make sure pdfplumber is installed: pip install pdfplumber');
    }

    $parsed = json_decode(file_get_contents($parsedPath), true);
    respond(['skills' => $parsed['skills'] ?? []]);

} elseif ($action === 'save') {

    $candidateId = $user['candidate_id'] ?? null;
    if (!$candidateId) {
        fail('Only candidates can save skills.');
    }

    chdir($projectRoot);
    $cmd = 'python python/insert_skills.py ' . escapeshellarg((string) $candidateId) . ' ' . escapeshellarg($jsonRelPath) . ' 2>&1';
    exec($cmd, $output, $code);

    if ($code !== 0) {
        fail('Failed to save skills: ' . implode(' | ', $output));
    }

    respond(['message' => 'Skills saved to your profile.']);

} else {
    fail('Unknown action.');
}
