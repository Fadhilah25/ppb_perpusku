import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/transaction.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

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
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  // Notifikasi langsung untuk buku yang sudah terlambat
  Future<void> showOverdueNotification(
    BorrowTransaction transaction,
    String bookTitle,
    String memberName,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'overdue_channel',
      'Overdue Notifications',
      channelDescription: 'Notifications for overdue books',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      transaction.id ?? 0,
      'Buku Terlambat!',
      '$memberName terlambat mengembalikan "$bookTitle". '
          'Terlambat ${transaction.daysOverdue} hari. '
          'Denda: Rp ${transaction.calculateFine()}',
      details,
    );
  }

  // Notifikasi reminder sebelum jatuh tempo
  Future<void> scheduleReturnReminder(
    BorrowTransaction transaction,
    String bookTitle,
    String memberName,
  ) async {
    // Reminder 1 hari sebelum jatuh tempo
    final reminderDate = transaction.dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      const androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Return Reminders',
        channelDescription: 'Reminders for upcoming book returns',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        transaction.id ?? 0,
        'Reminder: Pengembalian Buku',
        '$memberName, jangan lupa kembalikan "$bookTitle" besok!',
        tz.TZDateTime.from(reminderDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Notifikasi harian untuk semua buku terlambat
  Future<void> scheduleDailyOverdueCheck() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_check_channel',
      'Daily Overdue Check',
      channelDescription: 'Daily check for overdue books',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule untuk jam 9 pagi setiap hari
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      999, // ID khusus untuk daily check
      'Cek Buku Terlambat',
      'Ada buku yang perlu dicek status pengembaliannya',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
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

  // Notification untuk peminjaman sukses
  Future<void> showBorrowSuccessNotification(
    String bookTitle,
    String memberName,
    DateTime dueDate,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'borrow_channel',
      'Borrow Notifications',
      channelDescription: 'Notifications for successful book borrowing',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Peminjaman Berhasil!',
      '$memberName meminjam "$bookTitle". '
          'Jatuh tempo: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
      details,
    );
  }

  // Notification untuk pengembalian sukses
  Future<void> showReturnSuccessNotification(
    String bookTitle,
    String memberName,
    double fine,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'return_channel',
      'Return Notifications',
      channelDescription: 'Notifications for successful book returns',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final message = fine > 0
        ? '$memberName mengembalikan "$bookTitle". Denda: Rp $fine'
        : '$memberName mengembalikan "$bookTitle". Tepat waktu!';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Pengembalian Berhasil!',
      message,
      details,
    );
  }
}
