<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

$user = require_login();

try {
    $pdo = db();
    ensure_notifications_table($pdo);

    $userId = (int) $user['user_id'];
    $all    = isset($_GET['all']) && $_GET['all'] === '1';

    if ($all) {
        // Return full history (read + unread), newest first
        $stmt = $pdo->prepare(
            'SELECT notification_id, message, is_read, created_at
             FROM Notifications
             WHERE user_id = ?
             ORDER BY created_at DESC
             LIMIT 50'
        );
        $stmt->execute([$userId]);
        $notifications = $stmt->fetchAll();

        foreach ($notifications as &$n) {
            $n['is_read'] = (bool) $n['is_read'];
        }
        unset($n);
    } else {
        // Return only unread, then mark them as read (for dashboard toasts)
        $stmt = $pdo->prepare(
            'SELECT notification_id, message, created_at
             FROM Notifications
             WHERE user_id = ? AND is_read = 0
             ORDER BY created_at DESC
             LIMIT 20'
        );
        $stmt->execute([$userId]);
        $notifications = $stmt->fetchAll();

        if (!empty($notifications)) {
            $ids          = array_column($notifications, 'notification_id');
            $placeholders = implode(',', array_fill(0, count($ids), '?'));
            $pdo->prepare("UPDATE Notifications SET is_read = 1 WHERE notification_id IN ($placeholders)")
                ->execute($ids);
        }
    }

    respond(['success' => true, 'notifications' => $notifications]);
} catch (Throwable $e) {
    fail('Could not load notifications: ' . $e->getMessage(), 500);
}
