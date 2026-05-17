import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/student_hub/assignment_model.dart';

class StudentHubNotificationService {
  static final StudentHubNotificationService _instance =
      StudentHubNotificationService._internal();

  factory StudentHubNotificationService() {
    return _instance;
  }

  StudentHubNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init(String userId) async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        // Save token to Firestore
        await _saveFCMToken(userId, token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageTap(message);
      });
    }

    // Initialize local notifications
    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    _localNotifications.initialize(initSettings);
  }

  Future<void> _saveFCMToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Handling a foreground message: ${message.messageId}');

    // Show local notification for foreground message
    _showLocalNotification(
      title: message.notification?.title ?? 'Student Hub',
      body: message.notification?.body ?? '',
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('Message clicked: ${message.messageId}');
    // Handle navigation based on message data
    if (message.data.containsKey('student_hub_type')) {
      // Navigation will be handled by the app router
      debugPrint('Student Hub message tapped');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
     AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'student_hub_notifications',
      'Student Hub Notifications',
      channelDescription: 'Notifications for Student Hub activities',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6366F1),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().hashCode,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleAssignmentNotifications(
    AssignmentModel assignment,
    String userId,
  ) async {
    final now = DateTime.now();
    final dueDate = assignment.dueDate;

    // Notification 1: Immediate
    await _showLocalNotification(
      title: 'New Assignment',
      body: assignment.title,
      payload: 'assignment_${assignment.assignmentId}',
    );

    // Notification 2: 24 hours before due
    final hoursBeforeDue = dueDate.subtract(const Duration(days: 1));
    if (hoursBeforeDue.isAfter(now)) {
      await _scheduleLocalNotification(
        scheduledDate: hoursBeforeDue,
        title: 'Due Tomorrow',
        body: assignment.title,
        payload: 'assignment_${assignment.assignmentId}',
      );
    }

    // Notification 3: 1 hour before due
    final oneHourBeforeDue = dueDate.subtract(const Duration(hours: 1));
    if (oneHourBeforeDue.isAfter(now)) {
      await _scheduleLocalNotification(
        scheduledDate: oneHourBeforeDue,
        title: 'Due in 1 Hour',
        body: assignment.title,
        payload: 'assignment_${assignment.assignmentId}',
      );
    }

    // Notification 4: On due date if not submitted
    if (dueDate.isAfter(now)) {
      await _scheduleLocalNotification(
        scheduledDate: dueDate,
        title: 'Overdue',
        body: assignment.title,
        payload: 'assignment_${assignment.assignmentId}',
      );
    }
  }

  Future<void> _scheduleLocalNotification({
    required DateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
  }) async {
     AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'student_hub_assignments',
      'Assignment Reminders',
      channelDescription: 'Reminders for assignment deadlines',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6366F1),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.zonedSchedule(
      DateTime.now().hashCode,
      title,
      body,
      _convertToScheduleTime(scheduledDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  tz.TZDateTime _convertToScheduleTime(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  Future<void> sendGroupNotification(
    String groupId,
    String title,
    String body,
  ) async {
    try {
      // Fetch group document to get memberUids
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) return;

      final List<dynamic> memberUids = groupDoc.get('memberUids') ?? [];

      // Fetch FCM tokens for all members
      List<String> tokens = [];
      for (final memberId in memberUids) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();

          if (userDoc.exists && userDoc.get('fcmToken') != null) {
            tokens.add(userDoc.get('fcmToken') as String);
          }
       } catch (e) {
           debugPrint('Error fetching token for member $memberId: $e');
         }
      }

      // Write to notifications collection for Cloud Function to process
       if (tokens.isNotEmpty) {
         await FirebaseFirestore.instance.collection('notifications').add({
           'tokens': tokens,
           'title': title,
           'body': body,
           'groupId': groupId,
           'createdAt': FieldValue.serverTimestamp(),
           'processed': false,
         });
       }
     } catch (e) {
       debugPrint('Error sending group notification: $e');
     }
   }
}







