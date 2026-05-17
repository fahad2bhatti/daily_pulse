import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_hub_notification_service.dart';

final studentHubNotificationServiceProvider =
    Provider<StudentHubNotificationService>((ref) {
  return StudentHubNotificationService();
});

