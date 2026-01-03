class AppNotification {
  final String user;
  final String action;
  final String movieTitle;
  final String time;
  final bool isRead;

  AppNotification({
    required this.user,
    required this.action,
    required this.movieTitle,
    required this.time,
    this.isRead = false,
  });
}