<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$sessionUser = require_login();
$user = current_user_payload(db(), (int) $sessionUser['user_id']);

if (!$user) {
    session_destroy();
    fail('Session user no longer exists.', 401);
}

set_user_session($user);
respond(['success' => true, 'user' => $user]);
