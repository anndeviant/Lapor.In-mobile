import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 1)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String reportTitle;

  @HiveField(4)
  final String oldStatus;

  @HiveField(5)
  final String newStatus;

  @HiveField(6)
  final int reportId;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final bool isRead;

  @HiveField(9)
  final String? phoneNumber;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.reportTitle,
    required this.oldStatus,
    required this.newStatus,
    required this.reportId,
    required this.timestamp,
    this.phoneNumber,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? reportTitle,
    String? oldStatus,
    String? newStatus,
    int? reportId,
    DateTime? timestamp,
    bool? isRead,
    String? phoneNumber,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      reportTitle: reportTitle ?? this.reportTitle,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      reportId: reportId ?? this.reportId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'reportTitle': reportTitle,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'reportId': reportId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'phoneNumber': phoneNumber,
    };
  }
}
