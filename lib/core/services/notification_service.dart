import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../database/database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Request notification permission
    await Permission.notification.request();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screen based on payload
  }

  // Schedule daily check for overdue books
  Future<void> scheduleDailyOverdueCheck() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'overdue_channel',
      'Overdue Books',
      channelDescription: 'Notifications for overdue book reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule daily at 9 AM
    await _notifications.zonedSchedule(
      0,
      'Pengingat Buku Terlambat',
      'Periksa buku yang terlambat dikembalikan',
      _nextInstanceOf9AM(),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  tz.TZDateTime _nextInstanceOf9AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Check and notify overdue books
  Future<void> checkAndNotifyOverdueBooks() async {
    await initialize();

    final dbHelper = DatabaseHelper();
    final overdueTransactions = await dbHelper.getOverdueTransactions();

    if (overdueTransactions.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'overdue_channel',
      'Overdue Books',
      channelDescription: 'Notifications for overdue book reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Peringatan Buku Terlambat!',
      '${overdueTransactions.length} buku terlambat dikembalikan',
      details,
      payload: 'overdue_list',
    );
  }

  // Notify before due date (1 day before)
  Future<void> scheduleReturnReminder(
    int transactionId,
    String bookTitle,
    DateTime dueDate,
  ) async {
    await initialize();

    final reminderDate = dueDate.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Return Reminders',
      channelDescription: 'Reminders to return books before due date',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      transactionId + 1000, // Unique ID
      'Pengingat Pengembalian',
      'Buku "$bookTitle" harus dikembalikan besok!',
      tz.TZDateTime.from(reminderDate, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
