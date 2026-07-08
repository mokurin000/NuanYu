import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _careTimerChannelId = 'care_timer';
  static const String _careTimerChannelName = '关怀计时器';
  static const int _careTimerNotificationId = 1001;

  Future<void> init() async {
    if (_initialized) return;

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

    await _plugin.initialize(settings: initSettings);

    const androidChannel = AndroidNotificationChannel(
      _careTimerChannelId,
      _careTimerChannelName,
      description: '显示关怀计时器的进行状态',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<void> showCareTimerNotification({
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    if (!_initialized) await init();

    final timeText = _formatTime(remainingSeconds);

    final androidDetails = AndroidNotificationDetails(
      _careTimerChannelId,
      _careTimerChannelName,
      channelDescription: '显示关怀计时器的进行状态',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      usesChronometer: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: _careTimerNotificationId,
      title: '关怀计时器',
      body: '剩余时间: $timeText',
      notificationDetails: details,
    );
  }

  Future<void> updateCareTimerProgress({
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    if (!_initialized) return;
    await showCareTimerNotification(
      remainingSeconds: remainingSeconds,
      totalSeconds: totalSeconds,
    );
  }

  Future<void> cancelCareTimerNotification() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _careTimerNotificationId);
  }

  Future<void> showCareTimerCompleteNotification() async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      _careTimerChannelId,
      _careTimerChannelName,
      channelDescription: '关怀计时器完成通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: _careTimerNotificationId,
      title: '关怀计时器',
      body: '计时完成！',
      notificationDetails: details,
    );
  }

  void dispose() {
    _plugin.cancelAll();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
