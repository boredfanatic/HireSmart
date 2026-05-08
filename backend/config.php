<?php
declare(strict_types=1);

session_start();

header('Content-Type: application/json; charset=utf-8');

const DB_HOST = '127.0.0.1';
const DB_NAME = 'HireSmart';
const DB_USER = 'root';
const DB_PASS = '';

function db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function json_input(): array
{
    $raw = file_get_contents('php://input');
    if (!$raw) {
        return $_POST;
    }

    $data = json_decode($raw, true);
    return is_array($data) ? $data : $_POST;
}

function respond(array $payload, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function fail(string $message, int $status = 400): void
{
    respond(['success' => false, 'error' => $message], $status);
}

function require_login(): array
{
    if (empty($_SESSION['user'])) {
        fail('Please log in first.', 401);
    }

    return $_SESSION['user'];
}

function current_user_payload(PDO $pdo, int $userId): ?array
{
    $stmt = $pdo->prepare(
        "SELECT u.user_id, u.email, u.user_type,
                c.candidate_id, c.full_name, c.phone, c.resume_path,
                e.employer_id, e.company_name, e.company_description
         FROM Users u
         LEFT JOIN Candidates c ON c.user_id = u.user_id
         LEFT JOIN Employers e ON e.user_id = u.user_id
         WHERE u.user_id = ?"
    );
    $stmt->execute([$userId]);
    $row = $stmt->fetch();

    if (!$row) {
        return null;
    }

    return [
        'user_id' => (int) $row['user_id'],
        'email' => $row['email'],
        'user_type' => $row['user_type'],
        'candidate_id' => $row['candidate_id'] !== null ? (int) $row['candidate_id'] : null,
        'employer_id' => $row['employer_id'] !== null ? (int) $row['employer_id'] : null,
        'name' => $row['user_type'] === 'employer' ? $row['company_name'] : $row['full_name'],
        'phone' => $row['phone'],
        'resume_path' => $row['resume_path'],
        'company_description' => $row['company_description'],
    ];
}

function set_user_session(array $user): void
{
    $_SESSION['user'] = $user;
}

function initials(?string $name): string
{
    $name = trim((string) $name);
    if ($name === '') {
        return 'U';
    }

    $parts = preg_split('/\s+/', $name);
    $letters = '';
    foreach ($parts as $part) {
        $letters .= strtoupper(substr($part, 0, 1));
        if (strlen($letters) >= 2) {
            break;
        }
    }

    return $letters ?: 'U';
}
