import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/notification.dart';
import '../models/report.dart';
import '../utils/hive_box.dart';
import 'auth_service.dart';
import 'report_service.dart';
import 'connectivity_service.dart';

class NotificationService {
  static final Logger _logger = Logger();
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Timer? _pollingTimer;
  static bool _isInitialized = false;
  static bool _isPolling = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.i('Initializing notification service');

    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
    _logger.i('Notification service initialized');
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to specific report if needed
  }

  // Start periodic polling for status changes
  static Future<void> startStatusPolling() async {
    if (_isPolling) return;

    _logger.i('Starting status polling');
    _isPolling = true;

    // Initial check
    await _checkForStatusChanges();

    // Start periodic polling every 10 minutes
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      await _checkForStatusChanges();
    });
  }

  // Stop status polling
  static void stopStatusPolling() {
    _logger.i('Stopping status polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  // Check for status changes
  static Future<void> _checkForStatusChanges() async {
    try {
      _logger.d('Checking for status changes');

      // Check connectivity first
      final hasConnection = await ConnectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('No internet connection, skipping status check');
        return;
      }

      // Get current user
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        _logger.w('No current user found, stopping status polling');
        stopStatusPolling();
        return;
      }

      // Get current reports
      final reports = await ReportService.getReportsByTrackingId(
        currentUser.phoneNumber,
      );

      // Get stored statuses
      final statusBox = await Hive.openBox<Map>(HiveBox.reportStatuses);
      final storedStatusesRaw = statusBox.get(currentUser.phoneNumber);
      final storedStatuses = Map<String, String>.from(
        storedStatusesRaw ?? <String, String>{},
      );

      // Check for changes
      bool hasChanges = false;
      final Map<String, String> newStatuses = {};

      for (final report in reports) {
        if (report.id == null) continue;

        final reportId = report.id.toString();
        final currentStatus = report.status ?? 'pending';
        newStatuses[reportId] = currentStatus;

        final storedStatus = storedStatuses[reportId];

        // If status changed, create notification
        if (storedStatus != null && storedStatus != currentStatus) {
          await _createStatusChangeNotification(
            report: report,
            oldStatus: storedStatus,
            newStatus: currentStatus,
          );
          hasChanges = true;
          _logger.i(
            'Status change detected for report ${report.id}: $storedStatus -> $currentStatus',
          );
        } else if (storedStatus == null) {
          // First time seeing this report, just store the status
          _logger.d(
            'New report detected: ${report.id} with status: $currentStatus',
          );
        }
      }

      // Update stored statuses
      if (newStatuses.isNotEmpty) {
        await statusBox.put(currentUser.phoneNumber, newStatuses);
      }

      if (hasChanges) {
        _logger.i('Status changes processed successfully');
      } else {
        _logger.d('No status changes detected');
      }
    } catch (e) {
      _logger.e('Error checking for status changes: $e');
    }
  }

  // Create notification for status change
  static Future<void> _createStatusChangeNotification({
    required Report report,
    required String oldStatus,
    required String newStatus,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      final timestamp = DateTime.now();

      // Get current user's phone number
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        _logger.w('No current user found, cannot create notification');
        return;
      }

      // Format status for display
      final oldStatusText = _formatStatusText(oldStatus);
      final newStatusText = _formatStatusText(newStatus);

      // Create notification object
      final notification = AppNotification(
        id: notificationId,
        title: 'Status Laporan Berubah',
        body: '${report.title} - $oldStatusText ke $newStatusText',
        reportTitle: report.title,
        oldStatus: oldStatus,
        newStatus: newStatus,
        reportId: report.id!,
        timestamp: timestamp,
        phoneNumber: currentUser.phoneNumber,
      );

      // Save to Hive
      final notificationBox = await Hive.openBox<AppNotification>(
        HiveBox.notifications,
      );
      await notificationBox.put(notificationId, notification);

      // Show local notification
      await _showLocalNotification(notification);

      _logger.i('Status change notification created for report ${report.id}');
    } catch (e) {
      _logger.e('Error creating status change notification: $e');
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(
    AppNotification notification,
  ) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'report_status_channel',
            'Report Status Updates',
            channelDescription: 'Notifications for report status changes',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.reportId,
        notification.title,
        notification.body,
        notificationDetails,
        payload: notification.id,
      );

      _logger.d('Local notification shown for report ${notification.reportId}');
    } catch (e) {
      _logger.e('Error showing local notification: $e');
    }
  }

  // Get all notifications for current user
  static Future<List<AppNotification>> getAllNotifications() async {
    try {
      // Get current user's phone number
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        _logger.w('No current user found, returning empty notifications');
        return [];
      }

      final notificationBox = await Hive.openBox<AppNotification>(
        HiveBox.notifications,
      );
      final allNotifications = notificationBox.values.toList();

      // Filter notifications by current user's phone number
      final userNotifications =
          allNotifications
              .where(
                (notification) =>
                    notification.phoneNumber == currentUser.phoneNumber,
              )
              .toList();

      // Sort by timestamp (newest first)
      userNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return userNotifications;
    } catch (e) {
      _logger.e('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notificationBox = await Hive.openBox<AppNotification>(
        HiveBox.notifications,
      );
      final notification = notificationBox.get(notificationId);

      if (notification != null) {
        final updatedNotification = notification.copyWith(isRead: true);
        await notificationBox.put(notificationId, updatedNotification);
        _logger.d('Notification $notificationId marked as read');
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  // Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      _logger.e('Error getting unread count: $e');
      return 0;
    }
  }

  // Clear all notifications for current user
  static Future<void> clearAllNotifications() async {
    try {
      // Get current user's phone number
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        _logger.w('No current user found, cannot clear notifications');
        return;
      }

      final notificationBox = await Hive.openBox<AppNotification>(
        HiveBox.notifications,
      );
      final allNotifications = notificationBox.values.toList();

      // Remove only notifications for current user
      for (final notification in allNotifications) {
        if (notification.phoneNumber == currentUser.phoneNumber) {
          await notificationBox.delete(notification.id);
        }
      }

      _logger.i(
        'All notifications cleared for user: ${currentUser.phoneNumber}',
      );
    } catch (e) {
      _logger.e('Error clearing notifications: $e');
    }
  }

  // Format status text for display
  static String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'verified':
        return 'Terverifikasi';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  // Format time with timezone
  static String formatTimeWithTimezone(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
