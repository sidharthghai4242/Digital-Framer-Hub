import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? message,
      notificationId,
      notificationTopic,
      title = "";
  Timestamp? date;

  NotificationModel();

  static NotificationModel toObject(doc) {
    NotificationModel model = NotificationModel();

    model.title = doc['title'];
    model.message = doc['message'];
    model.notificationId = doc['notificationId'];
    model.notificationTopic = doc['notificationTopic'];
    model.date = doc['date'] ?? Timestamp.now();

    return model;
  }

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = {};

    map['title'] = title ?? "";
    map['message'] = message ?? "";
    map['notificationId'] = notificationId ?? "";
    map['notificationTopic'] = notificationTopic ?? "";
    map['date'] = date ?? Timestamp.now();
    return map;
  }
}
