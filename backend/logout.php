<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

session_destroy();
respond(['success' => true]);
