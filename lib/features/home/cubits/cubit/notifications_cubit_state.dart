abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationUpdated extends NotificationState {
  final int count;
  final List<Map<String, dynamic>> notifications;

  NotificationUpdated({required this.count, required this.notifications});
}